use anyhow::{Context, Result};
use serde_json::json;
use std::env;
use tantivy::{query::QueryParser, schema::Value, Index};

fn main() -> Result<()> {
    // Get query from command line arguments
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        eprintln!("Usage: retrieve <query> [--category <category>] [--limit <n>]");
        std::process::exit(1);
    }

    // Parse arguments
    let mut query_terms = Vec::new();
    let mut category_filter = None;
    let mut limit = 12;
    let mut i = 0;

    while i < args.len() {
        match args[i].as_str() {
            "--category" => {
                i += 1;
                if i < args.len() {
                    category_filter = Some(args[i].clone());
                }
            }
            "--limit" => {
                i += 1;
                if i < args.len() {
                    limit = args[i].parse().unwrap_or(12);
                }
            }
            _ => query_terms.push(args[i].clone()),
        }
        i += 1;
    }

    let query_string = query_terms.join(" ");
    if query_string.is_empty() {
        eprintln!("Error: No query terms provided");
        std::process::exit(1);
    }

    // Open index
    let exe_path = std::env::current_exe()?;
    let exe_dir = exe_path
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .parent()
        .unwrap();
    let idx_dir = exe_dir.join("data/claude_idx");
    let index = Index::open_in_dir(&idx_dir)
        .with_context(|| format!("Failed to open index at {:?}", idx_dir))?;

    let reader = index
        .reader_builder()
        .reload_policy(tantivy::ReloadPolicy::Manual)
        .try_into()?;
    let searcher = reader.searcher();

    // Get schema fields
    let schema = index.schema();
    let path_field = schema.get_field("path").context("Missing path field")?;
    let chunk_field = schema.get_field("chunk").context("Missing chunk field")?;
    let category_field = schema
        .get_field("category")
        .context("Missing category field")?;
    let _timestamp_field = schema
        .get_field("timestamp")
        .context("Missing timestamp field")?;

    // Parse query
    let query_parser = QueryParser::for_index(&index, vec![chunk_field]);
    let query = query_parser.parse_query(&query_string)?;

    // Search
    let top_docs = searcher.search(&query, &tantivy::collector::TopDocs::with_limit(limit * 2))?;

    // Collect results
    let mut results = Vec::new();
    let mut seen_chunks = std::collections::HashSet::new();

    for (score, doc_address) in top_docs {
        if results.len() >= limit {
            break;
        }

        let doc: tantivy::TantivyDocument = searcher.doc(doc_address)?;

        // Apply category filter if specified
        if let Some(ref cat_filter) = category_filter {
            if let Some(cat_value) = doc.get_first(category_field) {
                if let Some(cat_str) = cat_value.as_str() {
                    if cat_str != cat_filter {
                        continue;
                    }
                }
            }
        }

        // Get document fields
        let path = doc
            .get_first(path_field)
            .and_then(|v| v.as_str())
            .unwrap_or("unknown");

        let chunk = doc
            .get_first(chunk_field)
            .and_then(|v| v.as_str())
            .unwrap_or("");

        let category = doc
            .get_first(category_field)
            .and_then(|v| v.as_str())
            .unwrap_or("general");

        // Skip duplicate chunks
        let chunk_hash = format!("{}-{}", path, &chunk[..chunk.len().min(50)]);
        if seen_chunks.contains(&chunk_hash) {
            continue;
        }
        seen_chunks.insert(chunk_hash);

        results.push(json!({
            "path": path,
            "category": category,
            "score": score,
            "content": chunk,
        }));
    }

    // Format output
    let mut context_parts = Vec::new();
    for result in &results {
        context_parts.push(format!(
            "=== {} ({})\n{}",
            result["path"].as_str().unwrap_or(""),
            result["category"].as_str().unwrap_or(""),
            result["content"].as_str().unwrap_or("")
        ));
    }

    // Suggest relevant tools based on query
    let tools = suggest_tools(&query_string);

    // Output JSON response
    let output = json!({
        "query": query_string,
        "category_filter": category_filter,
        "num_results": results.len(),
        "system": format!(
            "You are an AI assistant with access to the .claude knowledge base.\n\
             Query: '{}'\n\
             Found {} relevant chunks.\n\
             Suggested tools: {}",
            query_string, results.len(), tools
        ),
        "context": context_parts.join("\n\n---\n\n"),
        "results": results,
    });

    println!("{}", serde_json::to_string_pretty(&output)?);

    Ok(())
}

fn suggest_tools(query: &str) -> String {
    let query_lower = query.to_lowercase();
    let mut tools = Vec::new();

    if query_lower.contains("debug") || query_lower.contains("error") {
        tools.push("scratchpad.sh (for debugging notes)");
    }

    if query_lower.contains("pattern") || query_lower.contains("implement") {
        tools.push("scratchpad.sh new task");
    }

    if query_lower.contains("search") || query_lower.contains("find") {
        tools.push("grep, find");
    }

    if query_lower.contains("code") || query_lower.contains("function") {
        tools.push("code_index lookups");
    }

    if tools.is_empty() {
        "none specific".to_string()
    } else {
        tools.join(", ")
    }
}

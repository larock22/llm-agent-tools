use anyhow::Result;
use std::{fs, path::Path};
use tantivy::{doc, schema::*, Index};
use textwrap::fill;
use walkdir::WalkDir;

fn main() -> Result<()> {
    // Get the directory where the binary is located
    let exe_path = std::env::current_exe()?;
    let exe_dir = exe_path
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .parent()
        .unwrap();
    let idx_dir = exe_dir.join("data/claude_idx");
    fs::create_dir_all(&idx_dir)?;

    // Schema definition
    let mut schema_builder = Schema::builder();
    let path_field = schema_builder.add_text_field("path", STORED);
    let chunk_field = schema_builder.add_text_field("chunk", TEXT | STORED);
    let category_field = schema_builder.add_text_field("category", STORED | STRING);
    let timestamp_field = schema_builder.add_u64_field("timestamp", STORED);
    let schema = schema_builder.build();

    // Create or open index
    let index = if idx_dir.join("meta.json").exists() {
        Index::open_in_dir(&idx_dir)?
    } else {
        // Remove directory if it exists but has no valid index
        if idx_dir.exists() {
            fs::remove_dir_all(&idx_dir)?;
            fs::create_dir_all(&idx_dir)?;
        }
        Index::create_in_dir(&idx_dir, schema.clone())?
    };
    let mut index_writer = index.writer(50_000_000)?; // 50 MB RAM budget

    // Walk through .claude directory (relative to current working directory)
    let claude_dir = std::env::current_dir()?.join(".claude");
    eprintln!("Looking for .claude at: {:?}", claude_dir);
    eprintln!("Current directory: {:?}", std::env::current_dir()?);
    if !claude_dir.exists() {
        eprintln!(
            "Warning: .claude directory not found at {:?}. Creating empty index.",
            claude_dir
        );
    } else {
        for entry in WalkDir::new(&claude_dir)
            .into_iter()
            .filter_map(Result::ok)
            .filter(|e| !e.file_type().is_dir())
        {
            let path = entry.path();

            // Process markdown files and other text files
            match path.extension().and_then(|s| s.to_str()) {
                Some("md") | Some("txt") | Some("json") => {}
                _ => continue,
            }

            // Determine category from path
            let category = determine_category(path);

            // Read and process file
            let content = match fs::read_to_string(path) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("Error reading {:?}: {}", path, e);
                    continue;
                }
            };

            // Get file timestamp
            let timestamp = entry
                .metadata()
                .ok()
                .and_then(|m| m.modified().ok())
                .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
                .map(|d| d.as_secs())
                .unwrap_or(0);

            // Split content into chunks
            for paragraph in content.split("\n\n") {
                // Wrap long paragraphs
                for chunk in fill(paragraph, 1000).split("\n\n") {
                    let chunk_text = chunk.trim();
                    if chunk_text.is_empty() {
                        continue;
                    }

                    // Add document to index
                    index_writer.add_document(doc!(
                        path_field => path.display().to_string(),
                        chunk_field => chunk_text,
                        category_field => category.clone(),
                        timestamp_field => timestamp,
                    ))?;
                }
            }
        }
    }

    // Commit changes
    index_writer.commit()?;

    // Get index statistics
    let reader = index.reader()?;
    let searcher = reader.searcher();
    let num_docs = searcher.num_docs();

    println!("Index refreshed successfully!");
    println!("Location: {:?}", idx_dir.canonicalize()?);
    println!("Documents indexed: {}", num_docs);

    Ok(())
}

fn determine_category(path: &Path) -> String {
    let path_str = path.to_string_lossy();

    if path_str.contains("debug_history") {
        "debug_history".to_string()
    } else if path_str.contains("patterns") {
        "patterns".to_string()
    } else if path_str.contains("qa") {
        "qa".to_string()
    } else if path_str.contains("cheatsheets") {
        "cheatsheets".to_string()
    } else if path_str.contains("metadata") {
        "metadata".to_string()
    } else if path_str.contains("code_index") {
        "code_index".to_string()
    } else if path_str.contains("anchors") {
        "anchors".to_string()
    } else if path_str.contains("scratchpad") {
        "scratchpad".to_string()
    } else if path_str.contains("delta") {
        "delta".to_string()
    } else {
        "general".to_string()
    }
}

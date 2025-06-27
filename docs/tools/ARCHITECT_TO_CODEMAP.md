# Migration: architect.sh → codemap.sh

## Why the Change?

`architect.sh` was powerful but complex. In practice, LLM agents need quick, actionable intelligence - not comprehensive documentation. `codemap.sh` provides 80% of the value with 20% of the complexity.

## Key Differences

| architect.sh | codemap.sh |
|--------------|------------|
| Complex ADRs and flow diagrams | Simple bug→fix patterns |
| Manual file descriptions | Auto-detected file types & dependencies |
| Separate module/decision/flow docs | Unified cheatsheets per component |
| Heavy documentation burden | Lightweight, as-you-go approach |

## What Maps Where

- `architect describe` → `codemap label` (but simpler)
- `architect add-module` → `codemap cheat` (component cheatsheets)
- `architect add-decision` → Just use `codemap debug` for actionable patterns
- `architect add-flow` → Document in cheatsheets if needed
- `architect map` → `codemap map` (auto-detects more)

## Quick Migration

```bash
# If you have existing architect docs, you can keep them
# They'll stay in memory-bank/architecture/

# Start using codemap for new work
./codemap.sh init
./codemap.sh map

# Migrate key module docs to cheatsheets
# Example: Convert architecture/modules/auth.md to a cheatsheet
./codemap.sh cheat auth < memory-bank/architecture/modules/auth.md
```

## New Workflow

Instead of heavy upfront documentation:

1. **Auto-map first**: `./codemap.sh map` detects structure
2. **Label key files**: Only mark non-obvious purposes
3. **Cheatsheet APIs**: Just public interfaces and gotchas
4. **Log fixes**: Capture bug→fix patterns as they happen

## Benefits

- **Faster**: Auto-detection vs manual documentation
- **Actionable**: Cheatsheets and debug logs vs prose
- **Lightweight**: Update in seconds, not minutes
- **Agent-Friendly**: Structured data vs narrative docs
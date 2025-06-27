# Codemap Quick Start Guide

`codemap.sh` replaces the complex `architect.sh` with a lightweight, high-impact approach focused on what actually helps LLM agents.

## Philosophy: 80% Value, 20% Effort

Instead of complex architectural diagrams, we focus on three things that matter most:

1. **Module Metadata** - What each file is (impl/test/interface) and what it depends on
2. **Component Cheatsheets** - Public APIs, common patterns, and gotchas
3. **Debug History** - Reusable bug→fix patterns

## Quick Start

```bash
# Initialize codemap
./codemap.sh init

# Auto-scan your project (detects file types and dependencies)
./codemap.sh map

# See what was found
./codemap.sh summary
```

## Key Commands

### 1. Label Important Files
```bash
# Mark what files do
./codemap.sh label "src/auth.js" impl "JWT authentication core logic"
./codemap.sh label "src/auth.d.ts" interface "Auth module type definitions"
./codemap.sh label "tests/auth.test.js" test "Auth module unit tests"
```

### 2. Create Component Cheatsheets
```bash
# Quick inline cheatsheet
./codemap.sh cheat auth "# Auth Module
Public API:
- authenticate(user, pass): Promise<token>
- validateToken(token): Promise<user>

Common Issues:
- Tokens expire after 24h
- Rate limited to 10 attempts/min"

# Or open editor for detailed cheatsheet
./codemap.sh cheat database
```

### 3. Log Debug Patterns
```bash
# Record bug→fix pairs for future reference
./codemap.sh debug "JWT tokens not expiring" "Added expiry check in auth.js:42"
./codemap.sh debug "Database connection timeout" "Increased pool size in config.js"
```

### 4. Search Everything
```bash
# Find anything across metadata, cheatsheets, and debug history
./codemap.sh search auth
./codemap.sh search "connection timeout"
```

## Example Workflow

```bash
# Starting a new project
./codemap.sh init
./codemap.sh map                    # Auto-discover structure

# Document as you learn
./codemap.sh label "server.js" entry "Express server entry point"
./codemap.sh deps "server.js" "express" "auth" "database"

# Create cheatsheets for complex parts
./codemap.sh cheat api << 'EOF'
# API Endpoints

## Auth
- POST /login - Returns JWT token
- POST /logout - Invalidates token

## Users  
- GET /users - List users (paginated)
- GET /users/:id - Get user details
EOF

# Log issues as you fix them
./codemap.sh debug "CORS errors on /api/*" "Added cors middleware in server.js"
```

## Why This Works

- **Instant Context**: Agents see file purposes without searching
- **Fewer Mistakes**: Cheatsheets prevent API misuse
- **Learn from History**: Debug logs prevent repeated errors
- **Low Overhead**: Takes seconds to update, saves minutes of agent time

## Best Practices

1. **Label as You Go**: When you understand what a file does, label it
2. **Cheatsheet Key APIs**: Focus on public interfaces and common gotchas
3. **Debug Log Immediately**: Right after fixing a bug, log it
4. **Keep It Light**: Don't over-document, just capture high-value info
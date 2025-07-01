# Quick Workflow Example

## Scenario: Implementing a new feature

### 1. Start work session
```bash
./scratchpad.sh new task "add user authentication"
```

### 2. Take notes while working
```bash
./scratchpad.sh append task_add_user_authentication "Using JWT tokens"
./scratchpad.sh append task_add_user_authentication "Implemented middleware"
```

### 3. Complete and file
```bash
# Review the scratchpad
./scratchpad.sh complete task_add_user_authentication

# AI agent files to patterns/
# Then mark as filed
./scratchpad.sh filed task_add_user_authentication
```

### 4. Make it searchable
```bash
./claude-rag.sh build
```

### 5. Find it later
```bash
./claude-rag.sh query "JWT authentication"
```

## Result
Your implementation notes are now  stored and agle to be ragged
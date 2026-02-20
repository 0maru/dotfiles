---
allowed-tools: Bash(ls:*)
description: Create a new Claude Code custom command (.md file)
---

# Command Creator

Guide for creating effective Claude Code custom commands. Commands are markdown files placed in `commands/` directories that extend Claude Code's capabilities.

## Context

- Existing project commands: !`ls ~/.claude/commands/ 2>/dev/null; echo "---"; ls .claude/commands/ 2>/dev/null`
- User commands dir: `~/.claude/commands/`
- Project commands dir: `.claude/commands/`

## Command Anatomy

Every command is a single `.md` file:

```
command-name.md
├── YAML Frontmatter (optional)
│   ├── allowed-tools: auto-approved tool patterns
│   └── description: shown in /command list
└── Markdown Body
    ├── Context section (dynamic !`shell` interpolation)
    ├── Rules / constraints
    └── Task instructions
```

### Frontmatter

```yaml
---
allowed-tools: Bash(git:*), Bash(npm:*)
description: Short description shown in slash command menu
---
```

- `allowed-tools`: Bash patterns auto-approved without user confirmation
- `description`: Concise explanation of what the command does

### Dynamic Context

Use `!` backtick syntax to inject live shell output:

```markdown
- Current branch: !`git branch --show-current`
- Node version: !`node --version`
- Changed files: !`git status --short`
```

This runs at command invocation time and injects the output into the prompt.

## Design Principles

1. **Concise Context** — Only include what Claude doesn't already know. Every line costs tokens.
2. **Specificity Matching** — Be prescriptive for fragile operations (git, deploy), flexible for creative tasks (writing, analysis).
3. **Progressive Detail** — Start with high-level intent, add detail only where ambiguity exists.

## Creation Process

### Step 1: Understand the Use Case

Ask the user:
- What task should this command automate?
- What tools/CLIs does it need?
- Are there constraints or rules to enforce?
- Should it be user-scoped (`~/.claude/commands/`) or project-scoped (`.claude/commands/`)?

### Step 2: Draft the Command

Based on the answers:
1. Choose a descriptive filename (kebab-case, e.g., `deploy-staging.md`)
2. Define `allowed-tools` for any Bash commands that should auto-approve
3. Write dynamic context using `!` backtick for relevant state
4. Write clear rules and task instructions

### Step 3: Write and Verify

1. Write the `.md` file to the appropriate `commands/` directory
2. Verify the file is valid markdown with proper frontmatter
3. Test the dynamic context expressions to ensure they work

## Example Commands

### Simple: Run Tests

```markdown
---
allowed-tools: Bash(npm test:*), Bash(npx vitest:*)
description: Run tests and fix failures
---
## Context
- Test framework: !`cat package.json | jq -r '.scripts.test // "not configured"'`
- Changed files: !`git diff --name-only HEAD`

## Task
Run the test suite. If tests fail, analyze failures and fix them.
Focus on files that changed recently.
```

### Advanced: Deploy

```markdown
---
allowed-tools: Bash(git:*), Bash(npm run build:*), Bash(gh:*)
description: Build and deploy to staging
---
## Context
- Branch: !`git branch --show-current`
- Build status: !`npm run build --dry-run 2>&1 | tail -1`

## Rules
- NEVER deploy from main directly
- Always create a release tag
- Run tests before deploying

## Task
1. Verify we're not on main
2. Run tests
3. Build the project
4. Create a git tag
5. Deploy to staging
```

## Your Task

Help the user create a new Claude Code command. Follow the creation process above, asking clarifying questions as needed. Write the final `.md` file to the chosen directory.

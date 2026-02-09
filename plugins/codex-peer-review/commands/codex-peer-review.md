---
name: codex-peer-review
description: Trigger peer review validation with Codex CLI. Use without arguments for current changes, --base <branch> for specific branch comparison, or add a question for broad technical validation.
---

# Codex Peer Review Command

You have been explicitly asked to run peer review validation using OpenAI Codex CLI.

## Parse Arguments

Check for arguments in the command:
- `/codex-peer-review` - Review current changes (will ask what to review)
- `/codex-peer-review --base <branch>` - Review against specified branch
- `/codex-peer-review --uncommitted` - Review staged/unstaged/untracked changes only
- `/codex-peer-review --commit <SHA>` - Review a specific commit
- `/codex-peer-review <question>` - Validate answer to a broad technical question

## Execute

**IMPORTANT:** All peer review work MUST run as a subagent to keep the main context clean.

1. **Gather information** from the user (review type, branch, etc.)
2. **Dispatch to the `codex-peer-reviewer` agent** with the Task tool
3. **Return only the synthesized result** to the user

Based on the arguments:

### No arguments (ask user what to review)
**IMPORTANT:** Ask the user what type of review they want.

Use `AskUserQuestion` tool:
```yaml
question: "What would you like to review?"
header: "Review type"
options:
  - label: "Changes vs branch"
    description: "Compare current changes against a base branch (will ask which branch)"
  - label: "Uncommitted changes"
    description: "Review staged, unstaged, and untracked changes only"
  - label: "Specific commit"
    description: "Review changes from a specific commit (will ask for SHA)"
multiSelect: false
```

#### If "Changes vs branch" selected
Ask for the base branch:
```yaml
question: "Which branch should I compare against?"
header: "Base branch"
options:
  - label: "main"
    description: "Compare against the main branch"
  - label: "develop"
    description: "Compare against the develop branch"
  - label: "master"
    description: "Compare against the master branch"
multiSelect: false
```
Then run: `codex review --base [branch] "[focus area if any]"`

#### If "Uncommitted changes" selected
Run: `codex review --uncommitted "[focus area if any]"`

#### If "Specific commit" selected
Ask: "What is the commit SHA to review?"
Then run: `codex review --commit [SHA] "[focus area if any]"`

### With explicit flags
Use the specified flag directly:
- `--base <branch>`: `codex review --base [branch]`
- `--uncommitted`: `codex review --uncommitted`
- `--commit <SHA>`: `codex review --commit [SHA]`

### Handling "no changes" case
If codex review reports no changes to review, inform the user:
"No changes found to review. Make sure you have uncommitted changes or specify a branch with divergent commits."

### With a question
This is a **design/architecture validation**:

Dispatch a subagent with:
```
Validate Claude's response to this question using Codex CLI.

Question: [the question from arguments]

Command: Use codex exec with output protection:
  timeout 120 codex exec <<'EOF' 2>&1 | head -c 500000
  [focused prompt about the question]

  IMPORTANT: Do not use any tools, do not read files, do not search code.
  Analyze ONLY the content provided in this prompt. Output text only.
  EOF

Return findings for comparison and synthesis.
```

## Dispatch to Agent

After gathering the review parameters, dispatch to the `codex-peer-reviewer` agent:

```
Use Task tool:
  subagent_type: "codex-peer-review:codex-peer-reviewer"
  prompt: |
    Run peer review validation.

    Type: [code-review | design | architecture | question]
    [For code-review]: Branch: [branch], Focus: [focus area if any]
    [For design/arch/question]: Claude's position: [summary]

    Return only the synthesized peer review result.
```

## Output

The agent will return a synthesized result. Present it to the user:
- **Validated**: Both AIs agreed
- **Resolved**: Disagreement resolved through discussion
- **Escalated**: Required external research (Perplexity/WebSearch)

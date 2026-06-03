---
name: codex-peer-review
description: Trigger peer review validation with Codex CLI. Default is symmetric blind-pass debate. Use --mode classic for legacy single-pass validation, init to set up Codex profiles, or pass a question for broad technical validation.
---

# Codex Peer Review Command

You have been explicitly asked to run peer review validation using OpenAI Codex CLI.

## Parse Arguments

```
/codex-peer-review                          → ask for scope, run blind-debate (default)
/codex-peer-review --base <branch>          → blind-debate vs branch
/codex-peer-review --uncommitted            → blind-debate of staged/unstaged/untracked
/codex-peer-review --commit <SHA>           → blind-debate of one commit
/codex-peer-review --mode classic [...]     → legacy single-pass validation (deprecated)
/codex-peer-review --mode blind-debate [...] → explicit default
/codex-peer-review init                     → write peer-review profile files to ~/.codex/
/codex-peer-review <question>               → blind-debate of an answer to a broad question
```

**Modes:**
- `blind-debate` (default): symmetric blind pass + per-issue debate. Best signal. See the `codex-peer-review` skill for full protocol.
- `classic` (deprecated): old behavior — Claude proposes, Codex validates, max 2 rounds. Cheaper but weaker. **Will be removed in a future version.** When this mode is invoked, warn the user once.

## init subcommand

Codex CLI uses **profile-v2 files**: `--profile <name>` layers `~/.codex/<name>.config.toml` on top of the base `~/.codex/config.toml`. Profiles are NOT `[profiles.*]` tables inside `config.toml` (that was the pre-0.12 scheme). The plugin writes one standalone file per profile and **never edits `config.toml`** — that file holds unrelated user settings.

If the user runs `/codex-peer-review init`, do not dispatch the agent. Instead:

1. **Check if the profile files already exist:**
   ```bash
   if [ -f ~/.codex/peer-review.config.toml ] && [ -f ~/.codex/peer-review-summarizer.config.toml ]; then
     echo "Profile files already exist. Nothing to do."
     exit 0
   fi
   ```

2. **Write the profile files:**
   ```bash
   mkdir -p ~/.codex
   cat > ~/.codex/peer-review.config.toml <<'EOF'
   model = "gpt-5.4"
   model_reasoning_effort = "high"
   EOF
   cat > ~/.codex/peer-review-summarizer.config.toml <<'EOF'
   model = "gpt-5.4-mini"
   model_reasoning_effort = "low"
   EOF
   ```

3. **Confirm to the user:**
   ```
   Wrote ~/.codex/peer-review.config.toml and ~/.codex/peer-review-summarizer.config.toml
   You can now run /codex-peer-review.
   ```

   If a legacy `[profiles.peer-review]` block still exists in `~/.codex/config.toml` from an older plugin version, mention that it is now inert and can be removed by hand — but do NOT edit `config.toml` yourself.

4. **Stop.** Do not dispatch the agent.

## Execute (non-init)

**IMPORTANT:** All peer review work MUST run as a subagent (`codex-peer-review:codex-peer-reviewer`) to keep the main context clean.

### Step 1: Pre-flight checks (in the main context)

```bash
command -v codex >/dev/null || { echo "ERROR: install codex CLI: npm i -g @openai/codex"; exit 1; }
command -v jq >/dev/null || { echo "ERROR: install jq: brew install jq"; exit 1; }
[ -f ~/.codex/peer-review.config.toml ] || {
  echo "ERROR: missing ~/.codex/peer-review.config.toml (Codex profile-v2 file)."
  echo "Run: /codex-peer-review init"
  exit 1
}
```

If any check fails, surface the error and stop. Do not dispatch.

### Step 2: Gather scope

If the user did not provide explicit scope flags or a question, use `AskUserQuestion`:

```yaml
question: "What would you like to review?"
header: "Review type"
options:
  - label: "Changes vs branch"
    description: "Compare current changes against a base branch"
  - label: "Uncommitted changes"
    description: "Review staged, unstaged, and untracked changes"
  - label: "Specific commit"
    description: "Review changes from a specific commit (will ask for SHA)"
multiSelect: false
```

If "Changes vs branch" is selected, ask for the base branch (do not auto-detect):

```yaml
question: "Which branch should I compare against?"
header: "Base branch"
options:
  - label: "main"
  - label: "develop"
  - label: "master"
multiSelect: false
```

If "Specific commit" is selected, ask for the SHA via free-form prompt.

### Step 3: Dispatch to the agent

```
Use Task tool:
  subagent_type: "codex-peer-review:codex-peer-reviewer"
  prompt: |
    Run peer review.

    Mode: blind-debate | classic   (default: blind-debate)
    Type: code-review | design | architecture | question
    Scope:
      [for code-review] base=<branch> | uncommitted | commit=<sha>
      [for design/arch/question] inline content
    Focus area: [optional, e.g. "security in auth flow"]

    Follow the codex-peer-review skill protocol exactly.
    Return only the synthesized verdict in the format documented in the skill.
```

### Step 4: Present the verdict

The agent returns a structured verdict (see the skill's "Output format" section). Present it to the user verbatim — do not re-summarize or re-classify.

## Mode warnings

If the user passes `--mode classic`:
> **Note:** `--mode classic` runs the legacy single-pass validation. The default `blind-debate` mode catches significantly more issues. Classic mode is deprecated and will be removed.

## Handling edge cases

- **No changes to review:** if `git diff <base>...HEAD` is empty, tell the user and exit before dispatching.
- **No question and no scope:** prompt via `AskUserQuestion` (above).
- **Codex auth missing:** the agent's pre-flight will catch this and surface `codex login`.

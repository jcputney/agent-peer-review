# Common Mistakes and Rationalizations

Anti-patterns that undermine peer review effectiveness. When you catch yourself thinking these things, stop and correct course.

## Using Invalid Codex CLI Flags (Critical)

The most expensive class of mistake — building workflows on flags that don't exist in the installed version.

| Wrong | Right | Why |
|-------|-------|-----|
| `codex review --json` | `codex exec --json` | `codex review` exposes only `--base` (verified on 0.136.0) — no machine-readable output |
| `codex review -o file` | `codex exec -o file` | Same — `codex review` has no `-o` |
| `codex exec --output-schema schema.json --json` | Use prompt-template schemas | The flag exists on 0.136.0 but the plugin does not depend on it; prompt-template + jq is version-stable |
| `codex exec resume <id> --output-schema ...` | Re-inject schema in the prompt | `resume` does not accept `--output-schema` |
| `-m gpt-5.3-codex-spark` (hardcoded) | `--profile peer-review-summarizer` | Hardcoded models drift; profiles let users tune |
| `-m gpt-5.4` (hardcoded) | `--profile peer-review` | Same — profiles centralize model config |

**Rule:** Anything that needs structured/streamed output goes through `codex exec`. `codex review` is for interactive human-readable review only, and even then we prefer `codex exec` so we can parse the result.

## Skipping Validation

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "It's just a typo fix" | Typo fixes can break builds, introduce bugs | Validate anyway |
| "I'm confident in this design" | Blind spots exist in every analysis | Validate anyway |
| "Codex will just agree" | The blind pass often surfaces things you missed | Run blind-debate |
| "User is waiting" | Bad advice wastes more time than validation | Validate first |
| "Similar to last time" | Context changes, different edge cases | Validate each time |
| "This is too simple" | Simple things have hidden complexity | Validate anyway |

## Protocol Drift (Asymmetric Thinking in Symmetric Mode)

`blind-debate` mode is symmetric. Both AIs get the **same prompt** with **no priming** about each other's likely findings. If you find yourself doing any of these, you're regressing to `classic` mode:

| Drift | Fix |
|-------|-----|
| "Let me describe Claude's position to Codex" | NO — Codex reviews independently first |
| "Codex will validate my findings" | NO — Codex produces its own findings, then they're merged |
| "I'll skip Round 0 and go straight to debate" | NO — the blind pass IS the value |
| "I already know what Codex will find" | Then you're priming yourself; run the blind pass |

## Convergence Mistakes

| Mistake | Reality | Fix |
|---------|---------|-----|
| Declaring `converged: true` from the model | Models will claim consensus to please you | Derive convergence from per-issue states only |
| Style disputes blocking convergence | Style debates never resolve | Drop `severity: style` from the loop entirely |
| Letting a `defend` survive round 3 without new evidence | Rationalization loop | Auto-defer if reasoning repeats |
| Promoting a `low` issue to `critical` mid-debate | Goalpost moving | New evidence required to re-rank severity |
| Treating `escalated` as resolution | Escalated means "carry forward, still unresolved" | Only `accepted/rejected/merged/deferred` are terminal |

## Skipping Canonicalization

| Mistake | Result |
|---------|--------|
| Sequential issue IDs (1, 2, 3...) | Same finding from both AIs enters debate twice |
| Skipping the merge step | Doubled false positives |
| Hashing on full claim text | Tiny wording differences create dupes |
| Hashing on file only | Different bugs in same file collapse |

**Rule:** `id = sha1(file + normalized_claim)`. Normalize whitespace and lowercase the claim before hashing.

## Premature Agreement

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "Codex is probably right" | Both AIs can be wrong | Verify with evidence in stances |
| "Don't want to argue with AI" | Technical truth matters more than peace | State your position |
| "Let's just pick one" | Both might have valid points | Let the state machine resolve it |
| "Whatever is faster" | Fast wrong is slower than slow right | Trust the protocol |

## Avoiding Escalation

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "External research is overkill" | Expert input prevents costly errors | Use for security/architecture |
| "We've debated enough" | Unresolved stays unresolved | Mark deferred, present as Contested |
| "Security concern seems minor" | Security is never minor | Always immediate-escalate security |
| "Don't want to slow down" | Wrong decisions cost more time | Take time to escalate |

## Subagent Misuse

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "I'll run Codex in the main context" | Fills main context with JSONL/transcripts | Always dispatch to the agent |
| "I need to see Codex output live" | Verdict is what matters | Trust the agent's progress task |
| "One quick check won't hurt" | Sets precedent for context pollution | Always dispatch |
| "The agent is slower" | Context pollution is worse than latency | Always dispatch |

## Forgetting Profile Configuration

| Mistake | Fix |
|---------|-----|
| Hardcoding `-m gpt-5.4` in prompts | Use `--profile peer-review` |
| Hardcoding `-m gpt-5.3-codex-spark` for summarization | Use `--profile peer-review-summarizer` |
| Skipping the pre-flight check for the profile | Run the check; surface init instructions if missing |
| Editing prompts to set `model_reasoning_effort` | That belongs in the profile, not the prompt |

If `~/.codex/peer-review.config.toml` is missing, tell the user to run `/codex-peer-review init`. Do not invent fallback model names, and never write the profile file yourself — `init` owns that.

## Guessing the Base Branch

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "It's probably main" | Projects use different conventions | Ask via AskUserQuestion |
| "I can auto-detect with git" | Detection can fail or be wrong | Ask the user |
| "develop is the standard" | Many projects use main, master, trunk | Ask the user |

## Discussion Anti-Patterns

### Echo Chamber
- **Symptom:** Restating the same `defend` reasoning round after round
- **Fix:** Auto-defer if reasoning substring matches a prior round

### Goalpost Moving
- **Symptom:** Severity bumped or scope shifted mid-debate without new evidence
- **Fix:** Lock in original severity unless new evidence justifies promotion

### Appeal to Authority
- **Symptom:** "Codex is usually right about security" or "Claude knows the codebase better"
- **Fix:** Stances require evidence in `reasoning`, not reputation

### False Consensus
- **Symptom:** Both sides emit `accept` without actually verifying the issue
- **Fix:** `accept` reasoning must reference specific code or test, not "agreed"

## Recovery Strategies

### If validation was skipped
1. Stop presenting the result
2. Trigger blind-debate now
3. Update recommendation if needed
4. Explain the update honestly

### If the wrong mode was used
1. Acknowledge — `classic` mode is weaker
2. Re-run in `blind-debate`
3. Note any new findings the symmetric pass surfaced

### If `--output-schema` was attempted and failed
1. The plugin does not rely on `--output-schema` — switch to prompt-template schemas (the SKILL.md prompts already do this)
2. Parse with `jq` against the `findings` / `stances` blocks

## Red Flags — STOP and Check

If you think any of these, pause and reconsider:

- "This doesn't need validation"
- "I'll just describe Claude's view to Codex" (regression to classic mode)
- "I'll declare convergence and move on" (no — let the state machine decide)
- "I'll use codex review with --json" (the flag does not exist)
- "I'll hardcode gpt-5.4 in the prompt" (use the profile)
- "Style issues should be in the verdict" (no — they go in style notes)
- "Round 3 with no new evidence is fine" (no — auto-defer)
- "I can skip the canonicalization step" (no — duplicates ruin the debate)

**All of these mean:** You should do the opposite of what you're considering.

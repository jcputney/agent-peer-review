# Common Mistakes and Rationalizations

Anti-patterns that undermine peer review effectiveness. When you catch yourself thinking these things, stop and correct course.

## Using the Wrong Codex Command

**This is the #1 mistake.** Using `codex review` when you should use `codex exec`.

| Situation | Wrong | Right |
|-----------|-------|-------|
| Validating a design proposal | `codex review --base develop` | `codex exec "Validate this design: ..."` |
| Validating a refactoring plan | `codex review --base develop` | `codex exec "Validate this refactoring: ..."` |
| Answering a broad question | `codex review --base develop` | `codex exec "Question: ..."` |
| Reviewing actual code changes | `codex exec "..."` | `codex review --base develop` |

**The rule:**
- `codex review --base X` = reviews the **entire git diff** against branch X
- `codex exec "..."` = executes a **focused prompt** about a specific thing

**If you're validating Claude's proposal/design/recommendation, use `codex exec`.** Only use `codex review` when you're actually reviewing code changes.

## Skipping Validation

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "It's just a typo fix" | Typo fixes can break builds, introduce bugs | Validate anyway |
| "I'm confident in this design" | Blind spots exist in every analysis | Validate anyway |
| "Codex will just agree" | Often finds different issues you missed | Let it check |
| "User is waiting" | Bad advice wastes more time than validation | Validate first |
| "Similar to last time" | Context changes, different edge cases | Validate each time |
| "This is too simple" | Simple things have hidden complexity | Validate anyway |
| "I already checked everything" | Fresh perspective catches what you normalized | Validate anyway |

**Rule:** If you're presenting a design, code review, or answering a broad question, validate with Codex.

## Premature Agreement

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "Codex is probably right" | Both AIs can be wrong | Verify with evidence |
| "Don't want to argue with AI" | Technical truth matters more than peace | State your position |
| "Let's just pick one" | Both might have valid points | Synthesize |
| "Two rounds is enough" | Major issues need proper resolution | Escalate if needed |
| "It doesn't matter much" | Small decisions compound | Decide correctly |
| "Whatever is faster" | Fast wrong is slower than slow right | Take time to verify |

**Rule:** Agreement should be based on evidence, not convenience.

## Avoiding Escalation

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "External research is overkill" | Expert input prevents costly errors | Use for major disputes |
| "We've discussed enough" | Unresolved stays unresolved | Escalate |
| "Security concern seems minor" | Security is never minor | Always escalate security |
| "Don't want to slow down" | Wrong decisions cost more time | Take time to escalate |
| "We can figure it out" | Two rounds failed; third won't help | Escalate |
| "User won't notice" | Users notice bugs and security issues | Escalate |
| "Perplexity isn't available" | WebSearch is a valid fallback | Use WebSearch instead |

**Rule:** If two rounds don't resolve it, escalate (Perplexity if available, WebSearch otherwise). If it's security, escalate immediately.

## Over-Escalation

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "Better safe than sorry" | Style ≠ safety | Reserve for real disputes |
| "Let external research decide everything" | Wastes time and resources | Try discussion first |
| "Not sure about anything" | Build confidence through process | Trust the protocol |
| "User will appreciate thoroughness" | User wants efficiency | Be judicious |

**Rule:** Escalate major disagreements, not minor preferences.

## Subagent Misuse

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "I'll run Codex in main context" | Fills context unnecessarily | Use subagent |
| "Subagent is slower" | Context pollution is worse | Use subagent |
| "I need to see Codex output live" | Summary is sufficient | Trust subagent |
| "One quick check won't hurt" | Sets bad precedent | Use subagent always |

**Rule:** Always dispatch Codex via subagent to preserve main context.

## Forgetting Session Continuity

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "I'll just run codex exec again" | Round 2 loses all Round 1 context | Use `codex exec resume [SESSION_ID]` |
| "Session IDs are complicated" | Just parse `thread_id` from JSON output | Use `--json` flag and extract ID |
| "It probably remembers anyway" | Each `codex exec` starts fresh | Always resume for Round 2 |
| "The prompt has enough context" | Codex's own reasoning from Round 1 is lost | Resume maintains full context |

**Rule:** Always capture session ID in Round 1 (`--json` flag) and resume it in Round 2 (`codex exec resume [ID]`).

## Guessing the Base Branch

| Rationalization | Reality | Correct Action |
|-----------------|---------|----------------|
| "It's probably main" | Projects use different conventions | Ask the user |
| "I can auto-detect with git" | Detection can fail or be wrong | Ask the user |
| "User won't want to be asked" | Wrong branch = useless review | Ask the user |
| "develop is the standard" | Many projects use main, master, trunk, etc. | Ask the user |

**Rule:** If the base branch is not explicitly provided, use `AskUserQuestion` to ask the user. Never guess.

## Discussion Anti-Patterns

### Echo Chamber
- **Symptom:** Restating same position with different words
- **Fix:** Require new evidence in each round

### Goalpost Moving
- **Symptom:** Disagreement shifts to new topic mid-discussion
- **Fix:** Lock in original dispute, address others separately

### Appeal to Authority
- **Symptom:** "Claude/Codex is usually right about this"
- **Fix:** Require codebase evidence, not reputation

### False Consensus
- **Symptom:** Claiming agreement when positions still differ
- **Fix:** Require explicit position statements that match

### Sunk Cost Fallacy
- **Symptom:** "We've discussed so long, let's just go with X"
- **Fix:** Escalate if truly unresolved

## Recovery Strategies

### If validation was skipped
1. Stop presenting result
2. Trigger validation now
3. Update recommendation if needed
4. Explain the update honestly

### If wrong conclusion reached
1. Acknowledge the error
2. Show correct analysis
3. Explain what was missed
4. Document for future

### If escalation needed after presentation
1. Inform user of uncertainty
2. Escalate to Perplexity
3. Update recommendation
4. Note correction in output

## Red Flags - STOP and Check

If you think any of these, pause and reconsider:

- "This doesn't need validation"
- "Codex will just agree anyway"
- "Security issue is probably fine"
- "No time for peer review"
- "I'll skip the subagent just this once"
- "Discussion is taking too long"
- "Let's not bother with external research"
- "User won't care about this detail"
- "The base branch is probably main/develop"
- "I can figure out the base branch from git"

**All of these mean:** You should do the opposite of what you're considering.

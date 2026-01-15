# Escalation Criteria

When to escalate disagreements for external research and authoritative resolution.

**Note:** Use Perplexity MCP if available. If Perplexity is not available, use WebSearch tool instead.

## Immediate Escalation (Skip Discussion)

These trigger direct escalation to external research - do not attempt discussion rounds:

| Category | Examples | Why Skip Discussion |
|----------|----------|---------------------|
| Security | Auth bypass, injection, secrets exposure | Risk too high for debate |
| Architecture | Fundamental design conflicts | Need expert judgment |
| Breaking Changes | Backward compatibility disputes | Impact too broad |
| Performance | Order-of-magnitude disagreements | Need verification |

**Rule:** If either AI flags a security concern, escalate immediately regardless of the other's opinion.

## Escalation After Discussion

After completing 2 discussion rounds, escalate if ANY of these apply:

### 1. No Convergence
- Positions remain fundamentally opposed
- New evidence in Round 2 didn't shift either position
- Both AIs maintain high confidence in conflicting views

### 2. Low Confidence, High Stakes
- Neither AI can provide strong evidence
- But the decision has significant consequences
- "We're both guessing on something important"

### 3. Novel Situation
- Neither AI has clear precedent to cite
- Project conventions don't cover this case
- Industry standards are ambiguous or conflicting

### 4. Factual Dispute
- Disagreement is about verifiable facts
- One AI might be working from outdated information
- External research can provide authoritative answer

## Do NOT Escalate

Reserve external research for genuine disputes. Do not escalate:

| Category | Why Not | Resolution |
|----------|---------|------------|
| Minor style disagreements | Not worth expert time | Defer to project conventions |
| Documentation wording | Subjective preference | Defer to Claude (user context) |
| Test coverage thresholds | Project-specific | Use project standards |
| Naming conventions | Style guide territory | Use project standards |
| Formatting preferences | Tooling handles this | Use formatter config |

## Escalation Message Templates

When escalating, frame the question neutrally.

### Option 1: Perplexity MCP (if available)

```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a senior software architect arbitrating between two AI code reviewers. Provide definitive guidance based on industry best practices and the specific context provided. Be direct and decisive."
    },
    {
      "role": "user",
      "content": "## Disagreement Context\n\n**Topic:** [specific technical question]\n**Codebase:** [language/framework/version]\n**Project Context:** [relevant constraints or patterns]\n\n**Claude's Position:**\n[position summary]\n- Evidence: [key evidence]\n- Reasoning: [technical reasoning]\n\n**Codex's Position:**\n[position summary]\n- Evidence: [key evidence]\n- Reasoning: [technical reasoning]\n\n**Discussion Summary:**\n[what was tried, why it didn't resolve]\n\n**Question:** Which approach is correct for this situation and why? Please be decisive."
    }
  ]
}
```

### Option 2: WebSearch (if Perplexity not available)

Use the WebSearch tool with focused queries:

```
Primary query: "[specific technical question] best practices [language/framework] [year]"

Follow-up queries if needed:
- "[Option A approach] vs [Option B approach] [language]"
- "[specific pattern] official documentation [framework]"
```

Look for:
- Official documentation
- Well-known engineering blogs (Google, Netflix, Uber, etc.)
- Stack Overflow answers with high votes and recent activity
- Language/framework RFCs or design documents

## Handling External Research Response

### Accept as Authoritative
- For this specific case, the research ruling is final
- Do not re-litigate after receiving response
- Apply ruling to the synthesis

### Document for Future
- Note the ruling in the final output
- Include source URLs when using WebSearch
- If pattern emerges, consider adding to project standards
- Help user understand the reasoning

### If Research is Inconclusive
If external research can't provide a clear answer:
1. Present both options to user with tradeoffs
2. Note the sources consulted and why they were inconclusive
3. Let user make final decision
4. Do not guess or flip a coin

## Escalation Flowchart

```
Disagreement detected
        |
        v
Is it security/architecture/breaking?
        |
    Yes |  No
        |   |
        v   v
   ESCALATE   Start Round 1
   NOW              |
                    v
              Resolved?
                |
            Yes | No
                |  |
                v  v
            Done   Round 2
                      |
                      v
                 Resolved?
                   |
               Yes | No
                   |  |
                   v  v
               Done   Any major issue
                      OR no convergence?
                         |
                     Yes | No (minor)
                         |  |
                         v  v
                    ESCALATE  Accept
                    NOW       partial
                              agreement
```

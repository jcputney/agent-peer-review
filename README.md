# Agent Peer Review

A Claude Code plugin marketplace for AI-to-AI peer validation. Multiple perspectives catch more issues than one.

## Available Plugins

### codex-peer-review

Peer validation using OpenAI Codex CLI. Validates Claude's designs, code reviews, and recommendations by getting a second opinion before presenting them to users.

## Installation

```bash
# Add this marketplace
/plugin marketplace add jcputney/agent-peer-review

# Install the Codex peer review plugin
/plugin install codex-peer-review
```

### Prerequisites for codex-peer-review

**Account Requirements:**
- **Claude Code**: Requires a Claude Pro ($20/mo), Max, Team Premium, or Enterprise subscription
- **OpenAI Codex CLI**: Included with ChatGPT Plus/Pro/Business/Edu/Enterprise plans, or use OpenAI API credits

**Install Codex CLI:**

```bash
# Install Codex CLI
npm i -g @openai/codex

# Authenticate (opens browser for OAuth or prompts for API key)
codex login
```

## How Peer Review Works

1. **Claude Forms Opinion**: Claude analyzes the task and forms a recommendation
2. **Dispatch to Reviewer**: A subagent runs the peer review agent to get a second opinion
3. **Compare Findings**: Results are classified as agreement, disagreement, or complement
4. **Resolution**:
   - **Agreement**: Synthesize and present combined view
   - **Disagreement**: Enter 2-round discussion protocol
   - **Persistent Conflict**: Escalate to Perplexity for arbitration

## codex-peer-review Features

- **Automatic Peer Review**: Auto-triggers before Claude presents implementation plans, code reviews, or architecture recommendations
- **Structured Disagreement Resolution**: 2-round discussion protocol with evidence-based arguments
- **Perplexity Arbitration**: Expert escalation for unresolved disputes or security concerns
- **Slash Command**: Explicit `/codex-peer-review` command for on-demand validation

### Usage

#### Automatic Mode

The plugin automatically triggers peer review when Claude is about to present:
- Implementation plans or designs
- Code review results
- Architecture recommendations
- Major refactoring proposals
- Answers to broad technical questions

#### Slash Command

```bash
# Review current changes against default branch
/codex-peer-review

# Review against specific branch
/codex-peer-review --base develop

# Validate answer to a broad question
/codex-peer-review "Should we use microservices or monolith for this project?"
```

### Command Selection

| Validation Type | Codex Command | Use When |
|-----------------|---------------|----------|
| Code Review | `codex review --base X` | Reviewing actual code changes (diffs) |
| Design Validation | `codex exec "..."` | Validating proposals, plans, architecture |
| Question Answering | `codex exec "..."` | Answering broad technical questions |

## Marketplace Structure

```
agent-peer-review/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace registry
└── plugins/
    └── codex-peer-review/         # Codex CLI peer review plugin
        ├── .claude-plugin/
        │   └── plugin.json        # Plugin metadata
        ├── agents/
        │   └── codex-peer-reviewer.md
        ├── skills/
        │   └── codex-peer-review/
        │       ├── SKILL.md
        │       ├── discussion-protocol.md
        │       ├── escalation-criteria.md
        │       └── common-mistakes.md
        ├── commands/
        │   └── codex-peer-review.md
        └── hooks/
            ├── hooks.json
            └── peer-review-reminder.sh
```

## Architecture

**Key Design:** All peer review work runs in a **subagent context** to keep the main conversation clean.

```
Main Conversation                    Subagent Context
       │                                    │
       │ 1. Claude forms opinion            │
       │                                    │
       ├──── dispatch to agent ────────────►│
       │                                    │ 2. Run peer review
       │                                    │ 3. Compare findings
       │                                    │ 4. Discussion rounds (if needed)
       │                                    │ 5. Escalate (if needed)
       │◄──── return synthesized result ────┤
       │                                    │
       │ 6. Present to user                 │
       ▼                                    ▼
```

## Adding Future Plugins

This marketplace is designed to host multiple peer review plugins. Future plugins could include:
- `claude-peer-review` - Claude reviewing Claude (different model versions)
- `gpt-peer-review` - GPT as the peer reviewer
- `gemini-peer-review` - Gemini as the peer reviewer

To add a new plugin, create a new directory under `plugins/` following the same structure.

## Contributing

Contributions are welcome! Please ensure any changes maintain the language-agnostic nature of the prompts and examples.

## License

MIT

## Related Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [OpenAI Codex CLI](https://github.com/openai/codex)
- [Claude Code Plugins Guide](https://code.claude.com/docs/en/plugins)

---

**Why two AIs?** Every analysis has blind spots. A second perspective from a different AI model catches issues that a single model might normalize or overlook. This peer validation approach provides higher-quality recommendations to users.

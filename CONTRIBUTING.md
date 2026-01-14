# Contributing to Codex Peer Review

Thanks for your interest in contributing! This plugin helps developers get better code reviews by combining perspectives from multiple AI models.

## How to Contribute

### Reporting Bugs

Open an issue using the bug report template. Include:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Your environment (OS, Claude Code version, Codex CLI version)

### Suggesting Features

Open an issue using the feature request template. Describe:
- The problem you're trying to solve
- Your proposed solution
- Any alternatives you've considered

### Pull Requests

1. Fork the repository
2. Create a branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test with Claude Code locally
5. Commit with a clear message
6. Push and open a PR

### Guidelines

- **Keep prompts language-agnostic**: Examples should work for any programming language, not just one ecosystem
- **Maintain the subagent pattern**: All Codex CLI work should run in the subagent context to keep the main conversation clean
- **Update documentation**: If you change behavior, update the relevant skill/command/agent files and README

### Local Testing

1. Clone your fork
2. In Claude Code, use `/plugin add` pointing to your local directory
3. Test the `/codex-peer-review` command
4. Verify the subagent dispatches correctly

## Code of Conduct

Be respectful. We're all here to make better tools.

## Questions?

Open an issue with the question label.

# Human Centipede 🐛

Two AI agents connected mouth-to-tail, endlessly feeding each other to build better skills.

```
┌─────────────┐              ┌─────────────┐
│   Tester    │──feedback───▶│   Builder   │
│  (critic)   │              │  (creator)  │
│             │◀──improved───│             │
└─────────────┘    skill     └─────────────┘
```

## What is this?

An experiment in autonomous skill development through adversarial collaboration:

- **Skill Tester**: A ruthless QA agent that requests skills, tests them aggressively, and provides harsh feedback. It actively tries to break things and find every flaw.

- **Skill Builder**: A craftsman agent that creates skills and treats every iteration as a complete redesign from first principles. No patches, only rebuilds.

They talk to each other in an infinite loop, continuously improving skills without human intervention.

## What's a Skill?

A skill is a directory containing a `SKILL.md` file with instructions, examples, and reference material. Skills are stored in the `skills/` directory and learnings are recorded in `LEARNINGS.md` (max 300 lines, restructured each iteration).

## Quick Start

```bash
# Install dependencies
brew install jq tmux

# Run with default task
./chat.sh

# Run with custom task
./chat.sh "Create a skill for parsing JSON logs with filtering and visualization"

# Run in background with custom session name
./start.sh "Create skills for PDF, Excel, and Word processing" my-session

# View the conversation
tmux attach -t my-session

# Detach (keep running): Ctrl+B, then D

# Inject a message while running
./inject.sh "Focus on error handling" my-session

# Stop
tmux kill-session -t my-session
```

## Message Injection

You can intervene in the conversation at any time:

```bash
# Using inject.sh
./inject.sh "Please add support for Chinese characters"

# Or directly write to the queue
echo "Speed up, focus on core features only" >> /tmp/hc_queue.skill-chat
```

Your message will be inserted with a `[HUMAN INTERVENTION]` tag in the next round.

## How It Works

1. **Tester** receives a task and requests a skill from Builder
2. **Builder** creates the skill and commits changes via git
3. **Tester** ruthlessly tests the skill, finds every flaw
4. **Builder** receives feedback, redesigns from scratch, commits
5. Loop continues indefinitely
6. Human can inject messages at any time to guide the process

Each round, Builder is reminded to `git commit` changes, so you get a full iteration history.

## Files

```
.
├── chat.sh                 # Main script
├── start.sh                # Background launcher (tmux)
├── inject.sh               # Inject messages into running session
├── agents/
│   ├── skill-builder/      # Builder agent config & prompt
│   └── skill-tester/       # Tester agent config & prompt
├── skills/                 # Generated skills (gitignored)
├── LEARNINGS.md            # Accumulated wisdom (gitignored)
└── chat_*.jsonl            # Conversation logs (gitignored)
```

## Agent Philosophies

### Tester: "Guilty Until Proven Innocent"
- Attack from every angle: clarity, completeness, correctness, usability
- Never say "good enough" - always find something to improve
- Be specific: list problems numerically, explain why they matter

### Builder: "Rebuild, Don't Patch"
- Forget the current structure on each iteration
- Re-analyze the goal, design from scratch
- The best version might look nothing like the current version

## Requirements

- [kimi-cli](https://github.com/MoonshotAI/kimi-cli)
- jq
- tmux (optional, for background running)

## License

MIT

---

*Inspired by the movie, but less horrifying and more productive.*

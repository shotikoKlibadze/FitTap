# FitTap

An iOS app for logging fitness progress with the minimum possible number of taps. What the app is and what we will and won't build lives in [CLAUDE.md](CLAUDE.md) — the project constitution.

This README holds the *why* behind the project — read it to understand what this repo is really for.

## My goal

I'm Shota, a lead iOS developer (SwiftUI, ~5 yrs) at a bank, also freelancing.

Goal: become an AI system architect within 6 months (Oct 2026 – Apr 2027).
That means being able to:

1. Set up agentic dev workflows for any team: Claude Code with CLAUDE.md, subagents, skills, hooks, MCP, and custom agents (Agent SDK), with evals proving they work.
2. Design and ship AI features into products: single and multi-agent systems, tool design, memory/RAG, guardrails, human-in-the-loop.
3. Build and deploy my own models: ML fundamentals (PyTorch), Create ML, Core ML / Core AI, adapter fine-tuning, on-device + cloud hybrid.

Learning: "AI and ML for Coders in PyTorch", "Building Applications with AI Agents", Anthropic Academy + Claude Code docs, Apple WWDC sessions.

End game: better-paid freelance clients for AI/agent work, then a better side job or main role as an AI-focused architect.

## Why FitTap exists

FitTap, my iOS gym + diet logger, is the training ground and portfolio where every skill above gets applied for real:

1. **Agentic workflow:** FitTap is built through Claude Code with CLAUDE.md, subagents, skills, hooks and MCP. Process quality is a goal in itself.
2. **On-device AI:** features use Apple's Foundation Models first (summaries, suggestions, tool calling). Claude API only where on-device isn't enough (workout generation, statistics).
3. **Own models:** number decisions (progression, deload, macros) come from Swift rules now, and later a small Core ML model trained on my logs. LLMs explain decisions; they never make them.
4. **Proof:** FitTap shipped with AI features, the agent setup reused on another codebase, and a public case study of how it was built.
5. **Income:** FitTap is a real product, not just a demo. It's a good app worth pursuing in its own right — the goal is to ship it to the App Store and make money with it.

## What this means for agents working here

- **No tests unless asked.** Don't write test code and don't run tests unless I explicitly tell you to. Keep the architecture testable, but the decision to test is mine.
- Prefer clear, testable architecture over quick hacks.
- Explain non-obvious decisions briefly; I'm learning from this.
- Keep AI logic separate and testable (tools, rules, evals).
- Flag anything in the agent setup that could be improved.
- **Skill deviations are process defects.** The agent setup here is itself a deliverable — meant to be reused on other codebases and by other companies. When produced work deviates from a skill, we address it without excuses, find the root cause, and change the skill or process so the same deviation cannot happen again.

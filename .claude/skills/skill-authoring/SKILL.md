---
name: skill-authoring
description: Use when creating, editing, or reviewing any part of the agent setup — a skill, rule, CLAUDE.md line, hook, slash command, subagent, or script — and whenever the user says "add that to the rules", "make this a rule", "make a skill for", "always do X from now on", or "never do X again". Decides which mechanism the rule deserves, then how to structure and word it so it is reusable in other projects. For drafting and testing a skill's content, use the skill-creator skill alongside this one.
---

# Skill authoring

The agent setup is a product in its own right: every rule, skill, and hook should be reusable outside the project it was born in. This skill holds the conventions; the `skill-creator` skill does drafting, evals, and description tuning.

## 1. Pick the mechanism before writing anything

"Add that to the rules" means: put the rule where it belongs — a skill, `CLAUDE.md`, a hook, a script, memory — not automatically `CLAUDE.md`. Never just transcribe a rule. Choose the strongest mechanism that fits, and say so when a stronger one than the user asked for fits better ("this is a good place for a hook").

| The rule… | Mechanism |
|---|---|
| applies to every task, and is short | a line in `CLAUDE.md` |
| applies only to certain files | a path-scoped rule (`.claude/rules/` with `paths`) or a skill with `paths` |
| is task knowledge, needed only for some work | a skill (lean `SKILL.md` + reference files) |
| is a workflow the user starts by name | a skill with `disable-model-invocation: true` (a slash command) |
| must never be broken, and a simple pattern catches it | a hook in `settings.json` |
| is a deterministic operation (validate, transform, parse) | a script the skill runs |
| needs a separate context (review, verification, research) | a skill with `context: fork`, or a subagent |
| needs outside data or actions | an MCP tool |
| needs proof that it works across many cases | an eval |
| is a fact about the user or project, not an instruction | memory |

Skills teach; hooks guard. A rule earns a hook only when a simple pattern catches it reliably, breaking it is costly or has already happened, and the rule is settled.

## 2. Write it to be reusable

- Generic phrasing first; project names, paths, and tokens only where the rule truly depends on them.
- Keep project-specific values in one place (a table, an example) so another project can swap them.
- Before adding, check existing skills and rules for overlap; extend one instead of creating a near-duplicate.

## 2a. Stay inside the size budget

The agent system must stay maintainable by one person; one that outgrows the product is a defect.

- Every addition names the real failure it prevents. No speculative rules.
- Prefer deleting or tightening an existing rule over adding a new one.
- Check the project's size budget (in this project: `Planning/AgentSystemPlanning.md` §6) before adding; if the addition crosses a limit, prune first and say so.
- A rule that never fired in months is a deletion candidate, not a keeper.

## 3. Structure a skill

- `SKILL.md` holds standing rules and a short "Rules recap". Keep it under 500 lines; ours stay far shorter.
- A loaded skill stays in the conversation and is not re-read, so write standing rules, not one-time steps.
- Long code examples go in `reference.md` (or a `references/` folder once there are several), linked by section from `SKILL.md`.
- Deterministic work goes in `scripts/`; the skill says **run** the script, never read it — only its output costs context.
- Templates and data files go in `assets/`.
- After compaction only the first 5,000 tokens of each loaded skill come back; put the most important rules first.

## 4. Write the description

- It is the only part Claude sees before loading, so it decides whether the skill triggers.
- Answer two questions: what the skill does, and when to use it.
- Use the words the user actually types ("sheet", "deep link", "#Preview"), not only formal names.
- Key use case first; the listing truncates at 1,536 characters.
- Not triggering? Add the missing trigger phrases.

## 5. Choose frontmatter deliberately

Default to `name` + `description` only. Add a field only for a reason, per [reference.md §1](reference.md#1-frontmatter-fields-and-when-to-use-them).

- `paths` hides the skill from prompt-only matching and loads it on Read, Write, or Edit of a matching file — so scope it to whole source folders, never narrow globs a brand-new file wouldn't hit before it is written, and never on skills triggered by phrases.
- Frontmatter `hooks` register only after the skill loads — never use them for guards that must always hold; those go in `settings.json`.
- `allowed-tools` pre-approves for one turn only and removes nothing; narrow `Bash` to patterns.
- Portable skills (claude.ai, API) accept only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.

## 6. Avoid the common failures

Details and fixes in [reference.md §4](reference.md#4-common-failures-and-fixes).

- **Structure:** each skill is `skills/<name>/SKILL.md` — exact file name, inside a named folder, valid YAML frontmatter. Plugin skills sit in `skills/` at the plugin root, not inside `.claude-plugin/`.
- **Distinct descriptions:** no two skills claim the same requests; overlap makes Claude pick the wrong one.
- **Distinct names:** avoid generic names (`code-review`, `testing`) that a plugin, personal, or enterprise skill may already use — the higher-priority one shadows yours.
- **Trigger coverage:** check the description against several phrasings of the same request ("profile this", "why is this slow?", "make this faster"); add the words of any that wouldn't match.
- **Scripts:** executable (`chmod +x`), forward-slash paths, and dependencies named in the description.

## 6b. Subagents

A subagent (`.claude/agents/<name>.md`) earns its place when work should run in its own context and return only a result. Template in [reference.md §5](reference.md#5-subagent-template).

**Decision rule: does the intermediate work matter?** No → delegate. Yes → keep it in the main thread.

- **Use for:** research and exploration, code review (fresh eyes on work the main thread wrote), and jobs that need a different system prompt or different preloaded skills.
- **Never for:** "expert" personas ("you are a Swift expert") — no capability the main thread lacks; sequential pipelines where each step needs the last one's discoveries (reproduce → debug → fix); test runners — failures need the full output, not a summary.

- **Description steers twice:** it decides when the main agent delegates *and* what it writes in the task prompt. Say when to use it, and what the caller must pass ("You must tell it precisely which files to review").
- **Automatic vs on request:** "use proactively" makes delegation automatic. Use it only when the project's workflow wants the extra run every time; otherwise trigger on the user's words.
- **Preload skills:** list the project skills it needs in `skills:` — subagents don't inherit the parent's skills, and built-in ones (Explore, Plan, general-purpose) never load them.
- **Least tools:** research = `Read, Grep, Glob`; review = add `Bash` with read-only commands named in the prompt; only implementers get `Edit, Write`.
- **Output format is mandatory:** fixed sections, ending in a verdict and an **Obstacles** section (workarounds, flags, quirks) so the main thread doesn't rediscover them. The format is the subagent's stopping point.
- **Model:** a cheaper model for routine checking; `inherit` when the job needs the main model's judgment.
- After creating one, check it appears in the available agent types; if it doesn't, restart the session.

## 7. After writing

- Report the mechanism decision in one line, even when a plain rule was right.
- If a hook was added or changed, pipe-test it with a fixture before declaring it done.
- Keep any index of the setup (memory, README) in sync with what was added.

## Rules recap

1. "Add to the rules" = put it where it belongs; mechanism first; say when a stronger one fits.
2. Generic wording; project specifics isolated. Stay inside the size budget; prune before adding.
3. Lean `SKILL.md` of standing rules; examples in references; scripts run, not read.
4. Descriptions say what and when, in the user's words.
5. Frontmatter only with a reason; guards live in `settings.json`, not skill hooks.
6. Valid structure, distinct names and descriptions, tested trigger phrasings, runnable scripts.
   Subagents: steering description, preloaded skills, least tools, fixed output with verdict and obstacles.
7. Report the mechanism decision; test hooks.

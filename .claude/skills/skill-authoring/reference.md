# Skill authoring — reference

Details for the rules in [SKILL.md](SKILL.md). Read the section a task needs.

## 1. Frontmatter fields and when to use them

| Field | Use when |
|---|---|
| `name` | Always; matches the folder name (lowercase, digits, hyphens, ≤ 64 chars). |
| `description` | Always; see SKILL.md §4. |
| `when_to_use` | Extra trigger phrases that would bloat the description. Appended to it in the listing. |
| `paths` | The skill only matters for certain source folders. YAML list or comma string of globs, relative to the working directory. |
| `disable-model-invocation: true` | A workflow the user starts by name (`/ingest-video`); Claude must not start it alone. |
| `user-invocable: false` | Background knowledge Claude loads itself; hide it from the `/` menu. |
| `argument-hint`, `arguments` | A slash-command skill that takes input (`[url]`), used as `$name` in the body. |
| `allowed-tools` | The skill runs the same tools every time and prompts are noise. Pre-approves for the invoking turn only. |
| `disallowed-tools` | The skill must not use certain tools (a read-only reviewer drops `Edit`, `Write`). |
| `model`, `effort` | A routine job that a cheaper model or lower effort handles fine, or a hard one that needs more. |
| `context: fork` (+ `agent`, `background`) | Work that should run in its own context and return only a result: review, verification, research. |
| `hooks` | Checks that matter only while the skill is in use. Registered on invocation, kept for the session. |
| `metadata`, `license`, `compatibility` | Packaging for sharing; Claude Code doesn't act on them. |

## 2. Examples

A file-scoped knowledge skill:

```yaml
---
name: previews
description: Use when writing any SwiftUI view, subview, or #Preview block…
paths:
  - "App/**/*.swift"
  - "Packages/**/*.swift"
---
```

A manual workflow with pre-approved tools:

```yaml
---
name: ingest-video
description: Ingest a conference video — transcript and code — into the knowledge library.
disable-model-invocation: true
argument-hint: "[video-url]"
allowed-tools: WebFetch, Read, Edit(Knowledge/**)   # path rules use Edit(...) for every file-writing tool
---
```

A forked read-only verifier:

```yaml
---
name: verify-change
description: Use after finishing a code change to check the diff against the project skills and report pass/fail with evidence.
context: fork
disallowed-tools: Edit, Write
allowed-tools: Read, Grep, Glob, Bash(git diff *)
---
```

## 3. Skill folder layout

```
skill-name/
├── SKILL.md        // standing rules + recap
├── reference.md    // or references/<topic>.md once there are several
├── scripts/        // run, never read
└── assets/         // templates, data
```

## 4. Common failures and fixes

| Symptom | Likely cause | Fix |
|---|---|---|
| Skill never triggers | Description doesn't overlap the request's meaning | Add the trigger phrases users actually say; retest with several phrasings |
| Skill missing from the list | Wrong location or name, or YAML that doesn't parse | `skills/<name>/SKILL.md`, exact file name; check with `claude plugin validate .claude/skills` or `claude --debug` |
| Wrong skill used | Two descriptions claim the same requests | Narrow each description to its own job; name what it is *not* for if needed |
| Skill ignored | A higher-priority skill (enterprise, personal) has the same name | Rename to something more distinct |
| Plugin skills missing | Plugin disabled, not reloaded, or skills inside `.claude-plugin/` | Check `/plugin` (Installed, Errors), run `/reload-plugins`, move skills to `skills/` at the plugin root, validate |
| Fails at runtime | Missing dependency, script not executable, backslash paths | Install and name dependencies in the description, `chmod +x`, forward slashes |

Before sharing skills with a team, run the validator on the skills folder — a natural step for a pre-commit hook or CI check.

## 5. Subagent template

```markdown
---
name: <role>-<job>                 # e.g. ios-reviewer; distinct, not generic
description: <what it does>. Use when <user's words / situation>. <What the caller must pass>.
tools: Read, Grep, Glob            # add Bash for read-only commands; Edit, Write only for implementers
model: sonnet                      # or haiku / opus / fable / inherit
color: blue
skills:                            # project skills it must follow; not inherited otherwise
  - <skill-name>
---

<One line: role and the single job.>

## How to <job>
<Numbered steps: inputs, fallback when none given, what to check, confirm before reporting.>

## Limits
<Tools and commands it must not use; work outside its job.>

## Output format
Return exactly these sections, then stop:
1. **Summary**
2. **<Findings>**, each with evidence (`file:line`, rule cited)
3. **Verdict**: <fixed values>
4. **Obstacles**: setup issues, workarounds, special flags, contradictions — or "None"
```

Working example: `.claude/agents/ios-reviewer.md`.

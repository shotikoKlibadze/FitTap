# Guides

Plain-English, colourful explainer pages for the human owner of this codebase. Agents write most of the code, so the owner no longer carries the wiring in their head from having typed it. Each guide answers, for one system: **what lives where, why it was decided that way, and how the pieces connect.** They are published as private claude.ai artifacts; this file is the index of their links.

Ask Claude to "open the SwiftData guide" (or any name below), or open the link yourself.

## Index

| Guide | Link | Covers | Source | Updated |
|---|---|---|---|---|
| SwiftData Rules | https://claude.ai/artifact/GbcaYPbSCSQY7AoLoT2Uth | How the app saves data: the layers, who may touch the database, the session lifecycle, how Stats counts, why each choice was made, build order | [SwiftDataRules.html](SwiftDataRules.html) · plan: [SwiftDataPlanning.md](../Planning/SwiftDataPlanning.md) | 2026-11-03 |

## When a guide is made or updated

- **Make one** when a system is designed or built: a persistence layer, navigation, dependency injection, an AI feature, a sync or backend layer. Whenever the owner would otherwise have to read code to remember how it works.
- **Update it** when that system's structure changes. The guide must never describe wiring that no longer exists. Bump the "Last updated" line and the date in the index.
- Status lines ("planned", "step 4 of 11") are updated as the build moves forward.

## How to write one

- **Plain English for a smart reader who didn't write the code.** Short sentences, everyday words, real examples (a concrete week, a concrete workout). Type names appear only as labels the reader will search for, never as the explanation.
- **Lead with the big picture:** one diagram or stack of who talks to whom, then the hard rules, then details.
- **Every decision carries its reason.** A choice without a why gets forgotten or undone.
- **Colourful and consistent:** one colour per layer or concept, reused in every section, readable in light and dark.
- **Include where things live** (a folder map) and **what's left** (the build order or parked questions).
- **Source of truth stays in the repo.** A guide summarises a plan or the code; it links to the detailed plan, and never contradicts it.

## How to publish

- The HTML source lives in this folder, one file per guide, named after the guide (`SwiftDataRules.html`).
- Publish it with the Artifact tool. To update an existing guide, republish **the same file path** in the same conversation, or pass the guide's link as `url` from a new conversation, so the link stays the same.
- Add or update the guide's row in the index above, and stage both files.

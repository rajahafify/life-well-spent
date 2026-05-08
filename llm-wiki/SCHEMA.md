# Wiki Schema

Per-project conventions. LLM proposes changes; user approves. Co-evolves
with the wiki.

## Domain

Wiki for the **Life Well Spent** Godot project — a personal life-tracking /
productivity game. In scope: game design decisions, architecture, art style,
mechanics, progress tracking, and any reference material used during
development. Out of scope: unrelated personal notes or unrelated project
research.

## Source buckets

- `papers/` — academic papers, preprints (e.g., gamification, habit science)
- `articles/` — blog posts, web clippings, tutorials
- `books/` — long-form references, game design books
- `transcripts/` — talks, podcasts, video summaries
- `conversations/` — agent sessions, design discussions
- `notes/` — pasted text, ad-hoc ideas, meeting notes
- `code-references/` — in-repo code (referenced, not copied)
- `figures/` — screenshots, diagrams, concept art (with companion `.md`)
- `external/` — datasets, audio samples (with companion `.md`)

## Topic taxonomy

- `game-design/` — core loops, mechanics, progression, UI/UX decisions
- `architecture/` — project structure, patterns, autoloads, systems
- `progression/` — how life data is tracked, milestones, gamification
- `assets/` — art style, audio design, visual identity
- `tech/` — Godot implementation details, MCP integration, scripts

## Page types

- `concept`, `decision`, `bug`, `open-question`, `source`, `reference`,
  `synthesis`, `stub` — see SKILL.md.
- Concept variants (taxonomy, implementation walkthrough) — see
  `quality.md`.

## Lint rules

- Stale-claim threshold: 30 days.
- Required tags: `[game-design, architecture, progression, assets, tech]`
  (only use tags from this set).
- Relative path verification: every `](*.md)` link must resolve from the
  file's directory.
- Bidirectional links: if page A links to B, B should link back.
- Tag presence: warn if `tags:` is missing on pages >100 lines.

## Notes

- Project uses Godot 4.6.2 with Forward Plus rendering.
- MCP integration via `gdai-mcp-plugin-godot`.
- Jolt Physics for 3D physics.

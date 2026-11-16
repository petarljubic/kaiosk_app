---
name: code-over-docs
description: Prefers executable code and Gherkin scenarios over new prose. Use when tempted to add a README, ADR, design note, or docstring to explain a change. The feature file is the behavior document.
---

# Code over documentation

Do not add documentation to explain a change. If a reader needs a paragraph, the code or the scenario is wrong. Fix the names, the boundaries, or the Gherkin.

Do not add documentation of these kinds:

- a new README section for a feature
- an ADR or design note
- a docstring or KDoc that restates the function name
- a comment that narrates control flow
- a markdown file whose only job is to describe code that was just written

Documents that may stay, because they are process or runbooks rather than a substitute for code:

- `AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md`
- `.ai/guardrails.md`, `.ai/decisions.json`, and `.ai/charter.md`
- `features/*.feature`
- `.ai/retros/*.md` written by the retro skill
- `.ai/mcp-contract.md`
- the how-to-run commands already in the charter

A library's public contract is its types and its tests, not a prose page. When behavior changes, change the approved feature file first through the specifier skill, then the code. Do not document the drift.

---
name: implement-from-spec
description: Implements an approved Gherkin feature and nothing beyond it. Use only after the user has given a green light for a feature file. Maps each scenario to a test and refuses work without a matching .approved file.
---

# Implement from spec

Do not start here. The specifier skill must already have written `features/<slug>.feature`, and the user must have given a green light for that file.

## Gate

1. Read the feature file and `.ai/guardrails.md`.
2. Create `features/<slug>.approved` only if the user has given a green light in this conversation and the file does not already exist. The approval file contains the ISO date, the phrase `approved-by-user`, and a hash of the feature file.
3. If the feature file changed after that hash, stop and return to the specifier skill.
4. If there is no green light, stop. Do not implement.

## Build

- Write or update a test for each scenario before the production code that satisfies it.
- Implement only behavior named in the approved scenarios.
- Do not add a convenience, a setting, or a second flow that no scenario describes.
- Follow `no-comments`, `code-over-docs`, and `code-health`.
- Stay inside the layers and dependency rules in `.ai/decisions.json`.
- Do not add a library that the charter does not already allow. Ask first.

## Finish

Run the lint, test, and architecture commands from `.ai/decisions.json`, then follow `verify-output` for this slug. Do not claim the feature is done until those checks pass and each scenario has evidence.

When the user says the feature is finished, tell them the retro skill is the next step. Do not run retro unless they ask.

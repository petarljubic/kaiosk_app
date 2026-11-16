---
name: implement-from-spec
description: Implements an approved Gherkin feature test-first, one scenario at a time, and nothing beyond it. Use only after the user has given a green light for a feature file. Names the data shape before logic, proves each scenario failing then passing, and refuses work without a matching .approved file.
---

# Implement from spec

Do not start here. The specifier skill must already have written `features/<slug>.feature`, and the user must have given a green light for that file.

## Gate

1. Read the feature file, `.ai/decisions.json`, and `.ai/guardrails.md`.
2. Create `features/<slug>.approved` only if the user has given a green light in this conversation and the file does not already exist. The approval file contains the ISO date, the phrase `approved-by-user`, and a hash of the feature file.
3. If the feature file changed after that hash, stop and return to the specifier skill.
4. If there is no green light, stop. Do not implement.

## Shape first

Before any logic, trace the code the feature touches and write down in the reply:

- the data shape: the domain types, their fields, and which states are legal
- its organizing structure: a typed model, a state machine, a table, or a cubit state, chosen over scattered booleans and branches
- the layer each new file lives in, per `.ai/decisions.json`
- the order of scenarios you will build, each ending in a passing check

Make illegal states unrepresentable in the types. Parse external data at the boundary (drift rows, Firebase documents, user input) and trust the domain types inside.

## Build one scenario at a time

For each scenario, in order:

1. Write the test that encodes the scenario. Domain and data get a unit test. A cubit gets a plain `flutter_test` test with `mocktail`. A visible result gets a widget test. Name the test after the scenario name and index.
2. Run only that test. Record that it fails, and that it fails for the reason the scenario names. A compile error or a wrong-reason failure is not a red test; fix the test first.
3. Make the smallest production change that makes it pass.
4. Run the test again and record that it passes. Then run `flutter test` so nothing earlier broke.
5. Look at the diff. Remove dead code, a one-caller wrapper, or a layer the scenario did not need.

Rules while building:

- Implement only behavior named in the approved scenarios. Do not add a convenience, a setting, or a second flow that no scenario describes.
- Test behavior a user of the code can observe. Do not assert private calls or mock the unit under test.
- Do not change a test to match a wrong implementation. Do not weaken an existing assertion.
- Fix the root cause. A guard is a fix only when the state it handles is legitimate.
- Follow `no-comments`, `code-over-docs`, and `code-health`.
- Stay inside the layers and dependency rules in `.ai/decisions.json`.
- Do not add a library that the charter does not already allow. Ask first.

If a scenario cannot be built as written, stop and return to the specifier skill. Do not reinterpret the scenario.

## Finish

Run `flutter analyze`, `flutter test`, and `python tools/policy/check_all.py`. All must pass.

Report, per scenario: the test name, the failing-before output, and the passing-after output. Then hand off to `verify-output` for this slug. Do not claim the feature is done until verify-output has evidence for every scenario.

When the user says the feature is finished, tell them the retro skill is available. Do not run retro unless they ask.

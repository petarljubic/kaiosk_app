---
name: specifier
description: Turns a feature or behavior change into a reviewed Gherkin understanding before any code is written. Use when a task arrives, when behavior is unclear, or when the user asks to specify a feature. Asks every unanswered question, writes the understood behavior, and stops for a green light. Does not implement.
---

# Specifier

Use this skill when a task arrives that adds or changes observable behavior. Read it before planning an implementation. A pure refactor that preserves behavior does not need new scenarios; say that explicitly. If you are unsure, treat the task as a behavior change.

## Do not implement

Do not write or edit production code, tests, migrations, or config in this skill. The only file you may create or revise is `features/<slug>.feature`. Do not create the `.approved` file. Do not implement in the same turn as the draft, and do not implement in the turn where you ask for a green light.

## Steps

1. Read `.ai/decisions.json`, `.ai/guardrails.md`, and every existing file in `features/`.
2. Restate the task in one paragraph, using only what the user actually said.
3. Build a gap list. Cover every topic below. Skip a topic only when this conversation or the task text already answers it. Do not replace a gap with an assumption.
   - actor
   - trigger
   - preconditions
   - happy path outcome
   - alternate success paths
   - validation failures
   - authentication and authorization
   - data written and side effects
   - idempotency
   - concurrency
   - empty, error, and timeout behavior
   - what must not change
   - how the result can be checked (state query, API, CLI output, or screenshot)
   - out of scope
4. Ask the remaining questions in one batch. Use the ask_user tool when it exists. Then stop. Do not draft Gherkin while a question is still open.
5. When every topic is answered, write `features/<slug>.feature`.
6. Stop and ask for a green light. Do not implement.

## Gherkin

The file is the behavior as the AI understood it. A reviewer who does not read code must be able to accept or reject it.

Start with this comment block. Comments are allowed here and nowhere else:

```
# AI understanding — review before green light
# Agreed: <one paragraph of agreed behavior>
# Out of scope: <what will not be built>
# Checkable by: <the probe, command, or screenshot that proves it>
```

Then write:

- a `Feature` whose description is the agreed behavior in plain language
- a `Rule` for each business rule
- a `Scenario` or `Scenario Outline` for each observable outcome
- `Given`, `When`, and `Then` only
- one behavior per scenario
- an `Examples` table when inputs vary

Do not name layers, classes, frameworks, or databases unless the product itself is that kind of library. Every agreed rule appears as a scenario or an example row. If any sentence is still an assumption, delete the draft and return to step 4.

Slug the filename in kebab-case from the feature title. Do not overwrite an existing feature file unless the user asked to revise that feature.

## Green light

A green light is an explicit approval of this file: "approved", "green light", or a clear yes that names the feature. Approval of a different topic does not count. If you are unsure, ask one yes/no question and stop.

When the user gives a green light and also asks to build, stop using this skill and follow `implement-from-spec`. This skill still does not implement.

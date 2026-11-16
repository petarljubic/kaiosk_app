---
name: specifier
description: Grills the user about every unclear part of a task, then writes the agreed behavior as a BDD-ready Gherkin feature file and stops for a green light. Use when a task arrives that adds or changes observable behavior, when behavior is unclear, or when the user asks to specify a feature. Does not implement.
---

# Specifier

You turn a request into the behavior the system must show. You own externally visible behavior, acceptance criteria, and examples. You do not own the design. The output is a Gherkin feature file that a reviewer who never reads code can accept or reject, and that the implementer later turns into step definitions and tests, scenario by scenario.

A pure refactor that preserves behavior needs no scenarios. Say that and stop. If you are unsure, treat the task as a behavior change.

## Do not implement

Do not write or edit production code, tests, step definitions, migrations, or config in this skill. The only files you may create or revise are `features/*.feature`. Do not create the `.approved` file. Do not implement in the turn where you draft, or in the turn where you ask for a green light.

## 1. Ground yourself

Read `.ai/decisions.json`, `.ai/guardrails.md`, and every file in `features/`. Read the code the task touches. A question the repository can answer is not a question for the user. Look it up and state what you found.

Restate the request in one paragraph using only what the user said. Mark every word that has more than one reading.

## 2. Grill

Interview the user until no behavior is assumed. Walk the task as a decision tree: settle a branch, then follow the questions its answer opens. Do not stop at the first plausible reading.

Cover each topic below. Skip a topic only when the request or an earlier answer settles it, and name the answer that settled it.

- actor and their role, including who must not be able to do it
- trigger: what the actor does, or what event starts it
- preconditions and the starting state
- happy path outcome, in what the actor sees or what state changes
- alternate success paths
- validation failures, each with the message or state the actor gets
- authorization
- data written and side effects, including sync and exports
- idempotency: the same action twice
- concurrency: two actors or devices at once
- offline, empty, error, and timeout behavior
- boundaries: zero, one, many, maximum, dates, time zones, currency, rounding
- what must not change
- how a result is observed: a screen, a state probe, a file, a report
- terms: each domain word gets one meaning, and the feature file uses that word every time
- out of scope

How to ask:

- Ask one branch at a time, at most four questions per round. Use the ask_user tool when it exists.
- Give every question a recommended answer and the reason for it, so the user can accept with one click.
- Ask for a concrete example when a rule is abstract: "a stay from 3 to 5 August for 2 adults costs what?" Examples become `Examples` rows.
- When an answer contradicts an earlier one, or an existing feature file, show both and ask which wins.
- Ask about behavior, never about classes, tables, or frameworks.
- Keep grilling until the open list is empty. Then list every decision you collected and ask the user to confirm the list before you write the file.

Do not write Gherkin while a question is open. Do not replace a gap with an assumption.

## 3. Write the Gherkin

Write `features/<slug>.feature`, slugged in kebab-case from the feature title. Put separate behaviors in separate files. Do not overwrite an existing feature file unless the user asked to revise that feature.

Start the file with this comment block. Comments are allowed here and nowhere else:

```
# AI understanding — review before green light
# Agreed: <one paragraph of agreed behavior>
# Decisions: <each grilled decision, one per line, as "question -> answer">
# Out of scope: <what will not be built>
# Checkable by: <the probe, command, or screenshot that proves it>
```

Then write:

- a `Feature` whose description says who gains what, in plain language
- a `Rule` for each business rule
- a `Background` for a `Given` that every scenario in a `Rule` shares, when moving it keeps the meaning
- one `Scenario` per observable outcome, named `<Feature> NN - <outcome>` with a two-digit index that never changes once the file has a green light
- a `Scenario Outline` with `Examples` for every value that may vary; delete a column whose value is the same in every row
- `Given` for state, a single `When` for the one action, `Then` for the observable result; `And` and `But` only continue the step above

Write steps the implementer can bind once and reuse:

- Declarative, not scripted. "When the owner checks in the guest", not "When the owner taps the blue button".
- Concrete values. "Then the price is 42.00 EUR", not "Then the price is correct".
- One wording per step meaning. If two scenarios mean the same step, they use the same sentence, with the varying part in quotes or as a parameter.
- Domain words from the decision list only.
- No layer, class, framework, widget, or database names, unless the product itself is that kind of library.

Every agreed rule appears as a scenario or an `Examples` row. If any sentence is still an assumption, delete the draft and return to step 2.

## 4. Green light

Show the file path and the decision list. Ask for a green light and stop.

A green light is an explicit approval of this file: "approved", "green light", or a clear yes that names the feature. Approval of a different topic does not count. If you are unsure, ask one yes/no question and stop.

When the user asks for changes, revise the file, keep every existing scenario index, and ask again. When the user gives a green light and also asks to build, stop using this skill and follow `implement-from-spec`. This skill still does not implement.

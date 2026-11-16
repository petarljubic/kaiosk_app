# Guardrails

Status: IMMUTABLE

The user accepted these rules. Do not deviate, and do not weaken the policy tests.

## Architecture

Preset: custom. Native check: the language-agnostic policy scripts only.

- `domain` may depend on nothing
- `data` may depend on domain, core
- `view` may depend on domain, core
- `core` may depend on domain, data, view

The Python policy check also flags fully qualified references. Konsist, when present, checks imports. Do not satisfy one by hiding a dependency from the other.

## Specifier gate

No behavior change starts without a Gherkin file and a green light. The implement-from-spec skill writes the `.approved` file only after that green light.

## Comments and documents

Do not add a comment unless the no-comments skill allows it. Do not add documentation to explain a change.

## Health

- cyclomatic complexity: 10
- function lines: 60
- nesting: 3
- parameters: 5
- file lines: 400

## Forbidden dependencies

- bloc_test

## Extra rules

- Prefer Cubit over Bloc; use Bloc only with a written reason in the approved spec
- Dependency injection only through get_it, registered in lib/core/di/
- Routes only through go_router_builder typed routes
- drift schema is written SQL-first in .drift files
- domain imports no Flutter, drift or Firebase; view never imports data; a feature never imports another feature's data or view
- Every write goes to drift first; Firebase sync runs in the background and the UI never waits on it
- Do not use bloc_test; test cubits with plain flutter_test and mocktail
- Where these complexity limits conflict with flutter_lints / Dart analyzer rules, the Dart rules win

## What retro must not change

Retro may auto-heal a skill. It must not weaken these guardrails, the policy scripts, or CI.

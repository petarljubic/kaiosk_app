# kAIosk

When a task arrives, use the specifier skill before any other work that changes behavior. Do not implement until the user gives a green light on the Gherkin file.

Status of the architecture charter: immutable. The user accepted these rules. Do not deviate, and do not weaken the policy tests.

## Gates

- Read `.ai/decisions.json` and `.ai/guardrails.md` before editing.
- Do not add a comment. Follow the no-comments skill.
- Do not add documentation to explain a change. Follow code-over-docs.
- Keep cyclomatic complexity and coupling inside the charter thresholds.
- Do not weaken `tools/policy` or the CI workflow.
- After the user says a feature is finished, the retro skill may auto-heal a skill. It must not weaken an immutable rule.

## Commands

- Lint: `python tools/policy/check_all.py`
- Test: `python tools/policy/check_all.py`
- Architecture: `python tools/policy/check_all.py`
- Build: `python tools/write_build_info.py`
- Start: `flutter run -d web-server --web-port 3000`
- State check: `GET http://127.0.0.1:3000`

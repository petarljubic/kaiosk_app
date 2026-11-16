---
name: retro
description: Runs after a feature is finished. Scans the conversation for mistakes that happened even though a skill was followed, then auto-heals the skill that allowed the mistake. Use when the user says a feature is done, asks for a retro, or asks the agent to learn from corrections.
---

# Retro

Run this only after a feature is finished. Do not run it mid-implementation, and do not use it to renegotiate the architecture.

## Scan

Scan the current conversation first. If a session-history tool is available, use it to read this session's turns for the same feature. Do not claim you scanned history you cannot see. Ignore turns that belong to a different feature.

Record each user correction, failed check, or repeated mistake. For each one, classify it:

- The user changed their mind. This is a decision request, not a skill bug.
- The agent ignored a skill. The skill stays. Add a louder check to that skill's finish list only.
- The agent followed a skill and the result was still wrong. That skill needs an auto-heal.
- The agent could not prove the result. `verify-output` is missing a probe.
- The specifier left a gap that became a wrong behavior. Add that topic to the specifier gap list.

## Auto-heal

Auto-heal means editing the skill file so the same mistake fails earlier next time.

Before editing, read `.ai/decisions.json`.

You may edit only paths under `retro_may_edit`. You may not edit `immutable_paths`. Immutable files include `.ai/decisions.json`, `.ai/guardrails.md`, `tools/policy`, and the CI workflow.

Agent instructions exist in both `.github/agents` and `.claude/agents`. An auto-heal that changes one must change the other in the same way.

Do not weaken a rule to make a past mistake look acceptable. Do not delete a scenario, a policy check, or an architecture rule. Do not add a comment exception, a layer dependency, or a documentation escape hatch.

A valid auto-heal adds the smallest missing check: a question the specifier should have asked, a verification step, a naming rule, or a refusal condition. The new text must be specific to the mistake, not a generic reminder to be careful.

If the only real fix would change an immutable decision, do not apply it. Write the proposal in the retro log and ask the user.

## Order

1. Write `.ai/retros/<date>-<slug>.md` first. Include the mistakes, the classification, the skill diff you intend, and anything you will not change.
2. Apply the skill edit.
3. Re-read the skill and confirm every phrase in `skills.contracts` for that skill is still present.
4. Run `python tools/policy/check_skills.py`.
5. If the check fails, revert the skill edit and say so. Do not weaken the contract to make the check pass.

## Log

The retro log is the only new document this skill creates. Include:

- feature slug
- mistakes, each with the user evidence
- skills changed
- skills deliberately left alone
- immutable changes that need a human decision

Do not rewrite history, and do not auto-heal a skill the conversation does not implicate.

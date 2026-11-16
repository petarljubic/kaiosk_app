---
name: retro
description: Reads a finished session, finds where the agent struggled, and proposes a severity-ranked list of fixes to checks, skills, and steering files. Applies only the fixes the user picks. Use only when the user invokes retro or asks the agent to learn from a session. Never runs on its own.
---

# Retro

Run this only when the user asks for it. A smooth session has little to teach. A session that was harder than it should have been is the input. Do not use retro to renegotiate the architecture, and do not use it to judge the code; that is a review.

## 1. Read the session

Read the current session. If the user names an earlier session and a session-history tool can read it, read that one instead. Do not claim you read history you cannot see. Ignore turns that belong to a different task.

Find the struggle moments:

- a user correction or a reversed decision
- a failed check, test, or build, and what fixed it
- a long search for a file, a command, or a fact
- a tool call that cost a lot and returned little
- a mistake the user caught that a tool could have caught
- information the agent needed and could not reach
- a skill step that was followed and still led to a wrong result
- a specifier gap that became a wrong behavior

Quote or point to the exact turn for each. A candidate with no session moment behind it is generic advice. Drop it.

## 2. Map each struggle to a fix

Pick the fix kind from the struggle, in this order of preference:

| Struggle | Fix |
|---|---|
| A mistake a tool could catch | An automated check: a lint rule, a test, a policy script, or a CI step |
| A judgement-call mistake | A rule in the skill that allowed it, as a question, a refusal, or a finish check |
| A specifier gap | A topic or a question in the specifier's grill list |
| A result the agent could not prove | A probe or a command in verify-output |
| A long search | A pointer in a file the agent already reads |
| Information the agent could not reach | Wider access: a log file, a state probe, an MCP tool |
| A costly tool call for little return | A cheaper command or tool |
| A steering line that changed nothing | Delete the line |
| The user changed their mind | No fix; record it as a decision |

A mechanical mistake becomes a check, not prose. Prose goes only to a real judgement call. Do not add a rule to `AGENTS.md` or `CLAUDE.md`; those load into every session. Put it in the skill that owns the step.

If an existing check could have caught the mistake but is not wired into CI or the policy script, propose wiring it. Do not propose a duplicate.

If the repository has no guard for the mistake at all, no policy check and no CI step, list that as its own finding.

## 3. Rank and propose

Order candidates by severity: what the mistake would cost if it happened again, not how loud it was. A quiet mistake that ships a wrong price outranks a loud failed build.

Write `.ai/retros/<date>-<slug>.md` with, for each candidate:

- rank and severity
- the session moment, quoted or pointed to
- the fix kind and the exact file
- the intended diff, as before and after text
- whether it touches an immutable path

Then list the candidates in the reply and stop. Change no file other than the retro log until the user picks.

## 4. Apply only the picked candidates

When the user picks candidates, auto-heal only those. Read `.ai/decisions.json` first.

- Edit only paths under `retro_may_edit`. Do not edit `immutable_paths`: `.ai/decisions.json`, `.ai/guardrails.md`, `.ai/charter.md`, `tools/policy`, and the CI workflow. A picked candidate that needs one of them stays a proposal and needs an explicit user authorization that names the file.
- Agent instructions exist in `.github/agents` and `.claude/agents`, and commands in `.github/prompts` and `.claude/commands`. Change both copies the same way.
- Do not weaken a rule to make a past mistake look acceptable. Do not delete a scenario, a policy check, or an architecture rule. Do not add a comment exception, a layer dependency, or a documentation escape hatch.
- The new text names the specific mistake. "Be careful" is not a fix.

After the edits:

1. Re-read each changed skill and confirm every phrase in `skills.contracts` for it is still present.
2. Run `python tools/policy/check_all.py`.
3. If a check fails, revert that edit and say so. Do not weaken the contract to make the check pass.
4. Update the retro log: applied, rejected by the user, and left for a human decision.

Do not rewrite history, and do not touch a skill the session does not implicate.

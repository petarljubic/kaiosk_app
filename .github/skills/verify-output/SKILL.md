---
name: verify-output
description: Proves an approved feature against the real system. Runs analysis, tests and policy checks, drives the running Flutter app through the official Dart and Flutter MCP server and the app MCP, captures a screenshot for visible results, and reports a verdict per scenario. Use after implementation and before claiming a feature is done.
---

# Verify output

Do not claim a feature is done because the code compiled or the implementer said so. Prove every approved scenario on the real artifact.

## 1. Load the target

Read `features/<slug>.feature` and `features/<slug>.approved`. If either is missing, stop and use the specifier skill. List every scenario by name and index. Each one ends this skill as pass, fail, or unverified.

## 2. Static and test checks

Run each command and keep its output:

1. `flutter analyze`
2. `flutter test`
3. `python tools/policy/check_all.py`

When the `dart` MCP server is connected, also run its analysis and test tools on the changed files. A failure in either the CLI or the MCP counts.

Map each scenario to the test that covers it, by scenario name. A scenario with no covering test cannot pass on tests alone.

## 3. The running app

`product.shape` is `ui`, so start the app and check the behavior where a user would see it.

1. Start the app. Prefer the Dart MCP's launch tool, and connect it to the Dart Tooling Daemon. Otherwise run the start command from `.ai/decisions.json` in the background.
2. Wait until the state check in `.ai/decisions.json` succeeds. If it never does, the run is unverified. Do not invent a passing result.
3. List the tools the `dart` server exposes and use the ones that apply:
   - runtime errors and app logs after each step, which must be empty of new errors
   - the widget tree, to confirm the widgets and text a scenario names
   - hot reload after a fix, instead of a restart
4. When `.mcp.json` defines the `app` server and the app exposes its probe, use it:
   - `health` before anything else
   - `get_state` for the scope named in the feature's "Checkable by" line
   - `invoke` only for actions an approved scenario names
   - `screenshot` when the scenario is visible

   If the `/__ai/*` routes do not exist yet, say so, and add them as part of making the feature checkable, in non-production profiles only. Do not mock a probe to force a pass.
5. Stop the app when done.

## 4. Screenshot

For each scenario with a visible result, save a screenshot under `.ai/evidence/<slug>/<index>.png`. Use, in order: the app MCP `screenshot`, a Dart MCP screenshot, the browser pane on the web build at the start URL, or `node tools/verify/capture.mjs <slug>` when Playwright is installed. Open the image and check it shows what the scenario says. If no capture works, mark the visual check unverified. Do not describe a screen you did not see.

## 5. Verdict

Reply with a table, one row per scenario: index, name, verdict, and evidence (the test name and its output line, the probe response, or the screenshot path). Below it, paste the tail of each command's output.

A scenario passes only with direct evidence. Green lint is not evidence for a scenario. Any fail or unverified row means the feature is not done; say what is missing and hand it back to `implement-from-spec`.

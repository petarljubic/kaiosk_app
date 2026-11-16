---
name: verify-output
description: Proves a change against the running system or its tests. Use after implementation and before claiming a feature is done. Checks state, calls the app MCP when the process is running, and takes a screenshot for UI results.
---

# Verify output

Do not claim a feature is done because the code compiled. Prove the approved scenarios.

## Connect

1. Read the matching `features/<slug>.feature` and its `.approved` file. If either is missing, stop and use the specifier skill.
2. Start the system with the start command in `.ai/decisions.json` when `product.shape` is `service`, `ui`, or `mobile`. For a `cli`, run the built binary. For a `library`, run the test command.
3. Wait until the state check in `.ai/decisions.json` succeeds. If no state check is configured, say so and do not invent a passing result.

## App MCP

When `.mcp.json` defines the `app` server, talk to the running process through that MCP:

- `health` before anything else
- `get_state` for the scope named in the feature's "Checkable by" line
- `invoke` only for actions the approved scenario names
- `screenshot` when the scenario is visible

If the MCP server is not running, start it from `.mcp.json` or call the same `/__ai/*` probe over HTTP. Do not skip the probe and do not mock it to force a pass.

The application must expose, in non-production profiles only:

- `GET /__ai/health`
- `GET /__ai/state?scope=`
- `POST /__ai/invoke`
- `GET /__ai/screenshot?name=` for UI and mobile shapes

If those routes do not exist yet, add them as part of making the feature checkable. Do not add them to a production profile.

## Screenshot

For a UI or mobile scenario, save a screenshot under `.ai/evidence/<slug>/`. Use the app MCP `screenshot` tool when the probe returns an image. Otherwise use a browser tool if one is already configured. If neither can capture, run `node tools/verify/capture.mjs <slug>` when Playwright is installed. If capture is impossible, say that the visual check is unverified. Do not describe a screen you did not see.

## Done

Every scenario in the approved feature has a matching check: an automated test, a state probe, or a screenshot. Paste the command output or the evidence path in the reply. A green lint run is not a substitute for the scenario check.

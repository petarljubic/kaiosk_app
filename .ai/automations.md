# Automations

## Active

- `.github/workflows/ci.yml` runs policy checks, the native lint and tests, the build, and uploads the build artifact.
- `tools/policy` fails the build on comment, architecture, skill-contract, and decision violations.
- `AGENTS.md` sends every behavior change through the specifier skill.

## Suggested, not installed

A prompt hook that repeats the specifier gate was not installed. A broken hook blocks every prompt. The gate already lives in AGENTS.md, CLAUDE.md, and the repository instructions.

After the git remote exists, require the CI check before merge.

For a UI product, install Playwright locally and run `node tools/verify/capture.mjs <slug>` when a browser tool is not already configured.

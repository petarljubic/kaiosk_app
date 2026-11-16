---
name: code-health
description: Enforces static code health close to CodeScene signals — cyclomatic complexity, nesting, function length, coupling, and brain methods. Use before finishing a change and when a lint or architecture check fails.
---

# Code health

Keep code healthy enough that a static analysis pass would not flag it. Thresholds live in `.ai/decisions.json` and are immutable. Do not raise them to land a change.

Before finishing, compare the change with every threshold:

- cyclomatic complexity at or below `max_cyclomatic`
- function length at or below `max_function_lines`
- nesting at or below `max_nesting`
- parameters at or below `max_parameters`
- file length at or below `max_file_lines`

Also refuse these patterns:

- coupling across a forbidden architecture edge
- a brain method that both decides and performs I/O; split the decision from the effect
- a copy of an existing block; extract one unit instead of duplicating
- a new behavior dropped into a file that is already over the line budget; extract a module
- a new framework, layer, or package the charter does not name

Run the language lint command from `.ai/decisions.json` and `python tools/policy/check_all.py`. Both must pass. If a native linter and the policy script disagree, follow the stricter result. Do not suppress the finding.

Hotspots are files that are both complex and frequently changed. You cannot see future change frequency. Treat a file that is already near the line or complexity cap as a hotspot and do not add behavior to it.

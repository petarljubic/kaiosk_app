---
name: no-comments
description: Stops explanatory comments from replacing clear code. Use when writing or reviewing code, when a comment seems necessary, or when comment-policy tests fail. Allows a comment only for a legal header, a named external bug, or a non-obvious invariant that cannot be a name, type, or test.
---

# No comments

Do not add a comment to explain what the next line does. Rename, extract, or encode the rule in a type or a test instead.

`tools/policy/check_comments.py` is the immutable check. Do not weaken it. Do not add a file to the allowlist to hide a comment. The allowlist in `.ai/decisions.json` is immutable and starts empty.

A comment may exist only when all of these are true:

- it records a legal or license header the project already requires, or
- it names an external bug id and the workaround that cannot be expressed in code, or
- it states an invariant that a name, a type, and a test cannot carry, or
- it is the AI understanding block in a `features/*.feature` file

Feature-file review comments are allowed. Source comments are not, including doc comments, TODOs, and commented-out code.

If a linter suppression is unavoidable, put the reason in the suppression syntax itself and add that exact line pattern only after the user accepts a change to the immutable comment policy. Until then, fix the code.

Before finishing, run `python tools/policy/check_comments.py`. If it fails, delete the comment and restructure the code. Do not disable the check.

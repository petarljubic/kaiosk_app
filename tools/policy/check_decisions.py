import json
import sys
from pathlib import Path


REQUIRED = (
    "status",
    "product",
    "git",
    "engineering",
    "commands",
    "complexity",
    "comments",
    "architecture",
    "skills",
    "immutable_paths",
    "retro_may_edit",
)

COMPLEXITY = (
    "max_cyclomatic",
    "max_function_lines",
    "max_nesting",
    "max_parameters",
    "max_file_lines",
)


def repo_root():
    for parent in Path(__file__).resolve().parents:
        if (parent / ".ai" / "decisions.json").is_file():
            return parent
    sys.exit("decisions.json not found")


def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)


def main():
    root = repo_root()
    path = root / ".ai" / "decisions.json"
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"decisions.json is not valid JSON: {error}")
    missing = [key for key in REQUIRED if key not in data]
    if missing:
        fail("decisions.json missing keys: " + ", ".join(missing))
    if data["status"] not in {"draft", "immutable"}:
        fail("status must be draft or immutable")
    for key in COMPLEXITY:
        value = data["complexity"].get(key)
        if not isinstance(value, int) or value < 1:
            fail(f"complexity.{key} must be a positive integer")
    rules = data["architecture"].get("rules")
    if not isinstance(rules, list) or not rules:
        fail("architecture.rules must be a non-empty list")
    contracts = data["skills"].get("contracts", {})
    required = data["skills"].get("required", [])
    if not required:
        fail("skills.required must list the generated skills")
    for name in required:
        phrases = contracts.get(name)
        if not isinstance(phrases, list) or not phrases:
            fail(f"skills.contracts.{name} must list required phrases")
    immutable = set(data["immutable_paths"])
    for required_path in (".ai/decisions.json", ".ai/guardrails.md", "tools/policy"):
        if required_path not in immutable and not any(
            item == required_path or item.startswith(required_path) for item in immutable
        ):
            fail(f"immutable_paths must protect {required_path}")
    print("decisions.json ok")


if __name__ == "__main__":
    main()

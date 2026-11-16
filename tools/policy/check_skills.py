import json
import sys
from pathlib import Path


def repo_root():
    for parent in Path(__file__).resolve().parents:
        if (parent / ".ai" / "decisions.json").is_file():
            return parent
    sys.exit("decisions.json not found")


def main():
    root = repo_root()
    data = json.loads((root / ".ai" / "decisions.json").read_text(encoding="utf-8"))
    contracts = data["skills"]["contracts"]
    violations = []
    for name in data["skills"]["required"]:
        path = root / ".github" / "skills" / name / "SKILL.md"
        if not path.is_file():
            violations.append(f"missing skill: {name}")
            continue
        text = path.read_text(encoding="utf-8")
        if f"name: {name}" not in text.split("---", 2)[1]:
            violations.append(f"{name}: frontmatter name must be {name}")
        for phrase in contracts[name]:
            if phrase not in text:
                violations.append(f"{name}: lost required phrase '{phrase}'")
    if violations:
        print("skill contract failed:", file=sys.stderr)
        print("\n".join(violations), file=sys.stderr)
        sys.exit(1)
    print("skill contract ok")


if __name__ == "__main__":
    main()

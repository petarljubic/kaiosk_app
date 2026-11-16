import json
import re
import sys
from pathlib import Path


def repo_root():
    for parent in Path(__file__).resolve().parents:
        if (parent / ".ai" / "decisions.json").is_file():
            return parent
    sys.exit("decisions.json not found")


def glob_to_regex(pattern):
    parts = []
    index = 0
    while index < len(pattern):
        if pattern.startswith("**/", index):
            parts.append("(?:.*/)?")
            index += 3
        elif pattern.startswith("**", index):
            parts.append(".*")
            index += 2
        elif pattern[index] == "*":
            parts.append("[^/]*")
            index += 1
        elif pattern[index] == "?":
            parts.append("[^/]")
            index += 1
        else:
            parts.append(re.escape(pattern[index]))
            index += 1
    return re.compile("^" + "".join(parts) + "$")


def matches_any(value, patterns):
    return any(pattern.match(value) for pattern in patterns)


def marker_found(text, marker):
    return re.search(re.escape(marker) + r"(?![A-Za-z0-9_])", text) is not None


def sibling_names(root, sibling_root):
    directory = root / sibling_root
    if not directory.is_dir():
        return []
    return sorted(path.name for path in directory.iterdir() if path.is_dir())


def owning_sibling(relative, sibling_root):
    prefix = sibling_root.strip("/") + "/"
    if not relative.startswith(prefix):
        return None
    rest = relative[len(prefix):]
    return rest.split("/", 1)[0] if rest else None


def main():
    root = repo_root()
    data = json.loads((root / ".ai" / "decisions.json").read_text(encoding="utf-8"))
    architecture = data["architecture"]
    source = [glob_to_regex(item) for item in architecture["source_globs"]]
    exempt = [glob_to_regex(item) for item in architecture.get("composition_root_globs", [])]
    rules = architecture["rules"]
    violations = []
    seen = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        if not matches_any(relative, source):
            continue
        seen.append(relative)
        if matches_any(relative, exempt):
            continue
        matched = False
        text = path.read_text(encoding="utf-8")
        for rule in rules:
            rule_globs = [glob_to_regex(item) for item in rule["source_globs"]]
            if not matches_any(relative, rule_globs):
                continue
            matched = True
            for marker in rule.get("forbidden_markers", []):
                if marker_found(text, marker):
                    violations.append(f"{relative}: forbidden dependency '{marker}' ({rule['name']})")
            sibling = rule.get("forbid_sibling_imports")
            if sibling:
                owner = owning_sibling(relative, sibling["root"])
                if owner:
                    for name in sibling_names(root, sibling["root"]):
                        if name == owner:
                            continue
                        for template in sibling.get("marker_templates", ["{name}"]):
                            marker = template.format(name=name)
                            if marker_found(text, marker):
                                violations.append(
                                    f"{relative}: sibling dependency '{marker}' ({rule['name']})"
                                )
        if not matched:
            violations.append(f"{relative}: source file is outside every architecture layer")
        limit = data["complexity"]["max_file_lines"]
        line_count = text.count("\n") + (0 if text.endswith("\n") or text == "" else 1)
        if line_count > limit:
            violations.append(f"{relative}: {line_count} lines exceeds max_file_lines {limit}")
    manifests = (
        "package.json",
        "build.gradle.kts",
        "pom.xml",
        "pyproject.toml",
        "go.mod",
        "Cargo.toml",
        "pubspec.yaml",
    )
    forbidden = data.get("forbidden_dependencies", [])
    for path in root.rglob("*"):
        if not path.is_file() or path.name not in manifests and path.suffix != ".csproj":
            continue
        text = path.read_text(encoding="utf-8")
        for name in forbidden:
            if name and name in text:
                violations.append(f"{path.relative_to(root).as_posix()}: forbidden dependency '{name}'")
    if violations:
        print("architecture policy failed:", file=sys.stderr)
        print("\n".join(violations), file=sys.stderr)
        sys.exit(1)
    if not seen:
        print("architecture policy ok (no source files yet)")
        return
    print("architecture policy ok")


if __name__ == "__main__":
    main()

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


def comment_lines(text, kind):
    found = []
    index = 0
    line = 1
    in_line = False
    in_block = False
    in_string = None
    triple = False
    escape = False
    length = len(text)
    while index < length:
        char = text[index]
        nxt = text[index + 1] if index + 1 < length else ""
        if char == "\n":
            line += 1
            in_line = False
            escape = False
            index += 1
            continue
        if in_line:
            index += 1
            continue
        if in_block:
            if char == "*" and nxt == "/":
                in_block = False
                index += 2
                continue
            index += 1
            continue
        if in_string:
            if triple and text.startswith(in_string * 3, index):
                in_string = None
                triple = False
                index += 3
                continue
            if escape:
                escape = False
                index += 1
                continue
            if char == "\\" and not triple:
                escape = True
                index += 1
                continue
            if not triple and char == in_string:
                in_string = None
            index += 1
            continue
        if kind in {"slash", "both"} and char == "/" and nxt == "/":
            found.append(line)
            in_line = True
            index += 2
            continue
        if kind in {"slash", "both"} and char == "/" and nxt == "*":
            found.append(line)
            in_block = True
            index += 2
            continue
        if kind in {"hash", "both"} and char == "#":
            found.append(line)
            in_line = True
            index += 1
            continue
        if char in {'"', "'", "`"}:
            if kind == "hash" and text.startswith(char * 3, index):
                in_string = char
                triple = True
                index += 3
                continue
            in_string = char
            triple = False
            index += 1
            continue
        index += 1
    return found


def kind_for(path):
    suffix = Path(path).suffix.lower()
    if suffix == ".py":
        return "hash"
    if suffix in {".kt", ".kts", ".java", ".cs", ".js", ".jsx", ".ts", ".tsx", ".go", ".rs", ".c", ".cpp", ".h"}:
        return "slash"
    return None


def main():
    root = repo_root()
    data = json.loads((root / ".ai" / "decisions.json").read_text(encoding="utf-8"))
    comments = data["comments"]
    scan = [glob_to_regex(item) for item in comments["scan_globs"]]
    allow = [glob_to_regex(item) for item in comments.get("allow_globs", [])]
    allow_lines = [re.compile(item) for item in comments.get("allow_line_patterns", [])]
    violations = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        if ".git/" in f"{relative}/" or relative.startswith(".git/"):
            continue
        if not matches_any(relative, scan) or matches_any(relative, allow):
            continue
        kind = kind_for(relative)
        if kind is None:
            continue
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        for line_number in comment_lines(text, kind):
            content = lines[line_number - 1] if line_number <= len(lines) else ""
            if line_number == 1 and content.startswith("#!"):
                continue
            if any(pattern.search(content) for pattern in allow_lines):
                continue
            violations.append(f"{relative}:{line_number}: {content.strip()}")
    if violations:
        print("comment policy failed:", file=sys.stderr)
        print("\n".join(violations), file=sys.stderr)
        sys.exit(1)
    print("comment policy ok")


if __name__ == "__main__":
    main()

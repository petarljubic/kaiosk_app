import subprocess
import sys
from pathlib import Path


def main():
    directory = Path(__file__).resolve().parent
    root = directory.parents[1]
    failed = False
    for name in (
        "check_decisions.py",
        "check_comments.py",
        "check_architecture.py",
        "check_skills.py",
    ):
        result = subprocess.run(
            [sys.executable, str(directory / name)],
            cwd=root,
        )
        failed = failed or result.returncode != 0
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()

from pathlib import Path
Path("dist").mkdir(exist_ok=True)
Path("dist/build-info.txt").write_text("ok\n", encoding="utf-8")

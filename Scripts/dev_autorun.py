#!/usr/bin/env python3
"""
Auto-restart DeskBuddy when source/resources change.

Usage:
  python3 scripts/dev_autorun.py
"""

from __future__ import annotations

import os
import signal
import subprocess
import sys
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WATCH_EXTENSIONS = {
    ".swift",
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".json",
}
WATCH_DIRS = [
    ROOT / "Sources",
    ROOT / "Package.swift",
]
IGNORE_DIR_NAMES = {
    ".build",
    ".git",
    ".swiftpm",
    "DerivedData",
}
POLL_SECONDS = 0.8


def should_ignore(path: Path) -> bool:
    return any(part in IGNORE_DIR_NAMES for part in path.parts)


def snapshot() -> dict[str, float]:
    state: dict[str, float] = {}
    for item in WATCH_DIRS:
        if not item.exists():
            continue
        if item.is_file():
            state[str(item)] = item.stat().st_mtime
            continue
        for path in item.rglob("*"):
            if not path.is_file():
                continue
            if should_ignore(path):
                continue
            if path.suffix.lower() not in WATCH_EXTENSIONS:
                continue
            state[str(path)] = path.stat().st_mtime
    return state


def start_app() -> subprocess.Popen:
    print("[dev_autorun] Starting: swift run DeskBuddy")
    return subprocess.Popen(
        ["swift", "run", "DeskBuddy"],
        cwd=ROOT,
        start_new_session=True,
    )


def stop_app(proc: subprocess.Popen | None) -> None:
    if proc is None:
        return
    if proc.poll() is not None:
        return
    print("[dev_autorun] Stopping previous DeskBuddy process...")
    try:
        os.killpg(proc.pid, signal.SIGTERM)
        proc.wait(timeout=5)
    except Exception:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except Exception:
            pass


def main() -> int:
    previous = snapshot()
    proc = start_app()
    print("[dev_autorun] Watching for file changes...")

    try:
        while True:
            time.sleep(POLL_SECONDS)
            current = snapshot()
            if current != previous:
                previous = current
                stop_app(proc)
                proc = start_app()
    except KeyboardInterrupt:
        print("\n[dev_autorun] Exiting...")
        stop_app(proc)
        return 0


if __name__ == "__main__":
    sys.exit(main())

"""Helper script to ensure that we blacken all Python files."""

# Standard Python Libraries
import argparse
import os
from pathlib import Path
import subprocess  # nosec B404
import sys

# Third-Party Libraries
from identify import identify


def main():
    """Build a list of paths to blacken and then call black."""
    parser = argparse.ArgumentParser(
        description="Given a path, find all Python files without a '.py' extension and call black on the given path and these files."
    )
    parser.add_argument(
        "-p",
        "--path",
        action="store",
        help="Path to search for Python files.",
        required=True,
    )
    args = parser.parse_args()

    root_path = Path(args.path)
    if not root_path.exists():
        print(f'Provided path "{root_path}" does not exist.')
        return 1

    # Black will search for easy-to-find Python files so we start with the root path
    paths_to_blacken = [root_path]

    python_files_found = 0

    # If we were given a directory then search for Python files. We will add any file
    # path that looks like a Python file but does not have a '.py' extension.
    if root_path.is_dir():
        for root, _, files in os.walk(root_path):
            for file in files:
                file_path = Path(root, file)
                if "python" in identify.tags_from_path(file_path):
                    python_files_found += 1
                    # We only care about Python files that do not have a '.py' extension here
                    if not file.lower().endswith(".py"):
                        paths_to_blacken.append(file_path)

    print(f"Found {python_files_found} Python files in {root_path}")

    # Since we are building the list of paths that are passed to the function call we
    # can safely ignore B603:subprocess_without_shell_equals_true.
    black = subprocess.run(  # nosec B603
        [sys.executable, "-m", "black", "--fast", *paths_to_blacken],
        capture_output=True,
        text=True,
    )

    # Print black's stdout if it has anything
    if black.stdout:
        print(black.stdout)

    # Print black's stderr if it has anything
    if black.stderr:
        # Filter out any lines with the Python 2 deprecation warning
        black_stderr_lines = black.stderr.splitlines()
        for line in black_stderr_lines:
            if not line.startswith("DEPRECATION: Python 2"):
                print(line)

    return black.returncode


if __name__ == "__main__":
    sys.exit(main())

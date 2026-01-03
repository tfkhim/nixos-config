#!/usr/bin/python3

import argparse
import os

from pathlib import Path
from subprocess import run


def find_terminfo_file(term: str) -> Path:
    def get_terminfo_path(base_dir: Path) -> Path:
        return Path(base_dir) / "terminfo" / get_terminfo_subpath(term)

    def exists_and_readable(terminfo_file: Path) -> bool:
        return terminfo_file.is_file() and os.access(terminfo_file, os.R_OK)

    base_dirs = os.environ.get("XDG_DATA_DIRS", "").split(":")

    valid_terminfo_files = filter(
        exists_and_readable, map(get_terminfo_path, base_dirs)
    )

    try:
        return next(valid_terminfo_files)
    except:
        raise RuntimeError(f"Couldn't find a terminfo file for '{term}'")


def get_terminfo_subpath(term: str) -> Path:
    return Path(term[0]) / term


def get_term() -> str:
    try:
        term = os.environ["TERM"]
        assert len(term) > 0
        return term
    except:
        raise RuntimeError("TERM environment variable is not set")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="copy-terminfo",
        description="Copies the terminfo file of the current terminal to a remote host",
    )
    parser.add_argument(
        "remote", nargs=1, help="The remote host specified as [user@]hostname"
    )
    parser.add_argument("-p", "--port", help="The sshd port on the remote host")

    args = parser.parse_args()
    remote = args.remote[0]

    term = get_term()
    terminfo_file = find_terminfo_file(term)

    def port_flag(flag: str) -> list[str]:
        return [flag, args.port] if args.port else []

    run(["ssh"] + port_flag("-p") + [remote, "mkdir", "-p", f"~/.terminfo/{term[0]}"])
    run(
        ["scp"]
        + port_flag("-P")
        + [str(terminfo_file), f"{remote}:~/.terminfo/{get_terminfo_subpath(term)}"]
    )

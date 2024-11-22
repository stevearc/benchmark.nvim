import os
import os.path

from nvim_doc_tools import parse_directory, render_md_api2, replace_section

HERE = os.path.dirname(__file__)
ROOT = os.path.abspath(os.path.join(HERE, os.path.pardir))
README = os.path.join(ROOT, "README.md")


def update_readme():
    types = parse_directory(os.path.join(ROOT, "lua"))
    funcs = types.files["benchmark/init.lua"].functions
    lines = ["\n"] + render_md_api2(funcs, types, 2) + ["\n"]
    replace_section(
        README,
        r"^<!-- API -->$",
        r"^<!-- /API -->$",
        lines,
    )


def main() -> None:
    """Update the README"""
    update_readme()

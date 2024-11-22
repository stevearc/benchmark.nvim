#!/usr/bin/env python
import argparse
import json
import math
import os
import platform
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import date
from typing import List, Optional

HERE = os.path.abspath(os.path.dirname(__file__))
ROOT = os.path.abspath(os.path.join(HERE, os.pardir, os.pardir))
sys.path.append(os.path.join(ROOT, "scripts"))

try:
    from nvim_doc_tools import format_md_table, replace_section
except ImportError:
    print(
        "Missing python libraries. Run 'make doc' from the repo root.", file=sys.stderr
    )
    sys.exit(1)

DIR_SIZES = [10, 100, 1000, 10000, 100000]
ITERATIONS = [100, 100, 40, 20, 10]
WARM_UP = 1
# Got these empirically from inspecting the html
COLORS = [
    "3498db",
    "2ecc71",
    "e74c3c",
    "f1c40f",
    "bdc3c7",
    "ffffff",
    "34495e",
    "9b59b6",
    "1abc9c",
    "e67e22",
]


@dataclass
class Plugin:
    name: str
    file: str
    repo: Optional[str] = None
    results: List[int] = field(default_factory=list)


PLUGINS = [
    Plugin("oil.nvim", "oil.lua", "stevearc/oil.nvim"),
    Plugin("vim-dirvish", "dirvish.lua", "justinmk/vim-dirvish"),
    Plugin("lir.nvim", "lir.lua", "tamago324/lir.nvim"),
    Plugin("mini.files", "mini.lua", "echasnovski/mini.nvim"),
    Plugin("nvim-tree.lua", "nvim_tree.lua", "nvim-tree/nvim-tree.lua"),
    Plugin("netrw", "netrw.lua"),
    Plugin("neo-tree.nvim", "neo_tree.lua", "nvim-neo-tree/neo-tree.nvim"),
]


def main() -> None:
    """Regenerate the benchmark graphs in the README"""
    global ITERATIONS
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument(
        "--debug-fast",
        action="store_true",
        help="Run fewer iterations for faster results",
    )
    parser.add_argument(
        "--debug-render", action="store_true", help="Use dummy data to test rendering"
    )
    args = parser.parse_args()

    if args.debug_fast:
        DIR_SIZES.pop()
        ITERATIONS = [5, 5, 2, 1]

    if args.debug_render:
        for plugin in PLUGINS:
            plugin.results = [i for i in DIR_SIZES]
    else:
        run_benchmarks()
    render_table()
    render_graph()
    render_signature(args)
    render_refs()


def run_benchmarks():
    for dir_size, iterations in zip(DIR_SIZES, ITERATIONS):
        for plugin in PLUGINS:
            cmd = f"nvim --clean -u {plugin.file} -c 'lua benchmark()'"
            subprocess.run(
                cmd,
                cwd=HERE,
                shell=True,
                check=True,
                env={
                    "PATH": os.environ["PATH"],
                    "DIR_SIZE": str(dir_size),
                    "WARM_UP": str(WARM_UP),
                    "ITERATIONS": str(iterations),
                },
            )
            with open(os.path.join(HERE, "tmp", "benchmark.json")) as f:
                stats = json.load(f)
                plugin.results.append(int(int(stats["avg"]) / 1e6))


def render_table():
    lines = ["\n"]
    cols = [f"{size:,} files" for size in DIR_SIZES]
    cols.insert(0, "Plugin")
    rows = []
    for plugin in PLUGINS:
        row = {"Plugin": plugin.name}
        for size, result in zip(DIR_SIZES, plugin.results):
            row[f"{size:,} files"] = f"{result:,}ms"
        rows.append(row)
    lines.extend(format_md_table(rows, cols))
    lines.append("\n")

    replace_section(
        os.path.join(HERE, "README.md"),
        r"^<!-- TABLE -->$",
        r"^<!-- /TABLE -->$",
        lines,
    )


def render_graph():
    lines = ["\n", "```mermaid\n", "xychart-beta\n"]
    lines.append(f'    x-axis "Num files" {DIR_SIZES}\n')
    lines.append('    y-axis "Render time log(ms)" 0 --> 4.5\n')
    legend = []
    for i, plugin in enumerate(PLUGINS):
        log_times = [str(math.log10(time)) for time in plugin.results]
        time_str = "[" + ", ".join(log_times) + "]"
        lines.append(f"    line {time_str}\n")

        color = COLORS[i % len(COLORS)]
        legend.append(
            f"![{plugin.name}](https://placehold.co/10x10/{color}/FFF?text=\\n) {plugin.name}"
        )
    lines.extend(["```\n", "\n"])
    lines.extend([" ".join(legend) + "\n", "\n"])

    replace_section(
        os.path.join(HERE, "README.md"),
        r"^<!-- GRAPH -->$",
        r"^<!-- /GRAPH -->$",
        lines,
    )


def render_signature(args):
    cmd = "./generate_graph.py"
    if args.debug_fast:
        cmd += " --debug-fast"
    if args.debug_render:
        cmd += " --debug-render"
    lines = [
        "\n",
        f"Last run on `{date.today().isoformat()}` with `{cmd}` \\\n",
        f"Platform: `{platform.platform()}` \\\n",
        "Neovim:\n",
        "```\n",
    ]
    proc = subprocess.run(["nvim", "--version"], check=True, stdout=subprocess.PIPE)
    for line in proc.stdout.decode().splitlines()[:3]:
        lines.append(line + "\n")
    lines.append("```\n")

    lines.append("\n")
    replace_section(
        os.path.join(HERE, "README.md"),
        r"^<!-- SIGNATURE -->$",
        r"^<!-- /SIGNATURE -->$",
        lines,
    )


def get_plugin_ref(plugin):
    if not plugin.repo:
        return None, None
    repo = os.path.join(ROOT, "plugins", os.path.basename(plugin.repo))
    proc = subprocess.run(
        ["git", "log", "-1", "--format=tformat:%h %cs"],
        cwd=repo,
        check=True,
        stdout=subprocess.PIPE,
    )
    return proc.stdout.decode().strip().split()


def render_refs():
    lines = [
        "\n",
        "Versions tested:\n",
        "\n",
    ]
    for plugin in PLUGINS:
        ref, date = get_plugin_ref(plugin)
        if ref is not None and date is not None:
            lines.append(f"- {plugin.name}: `{ref}` ({date})\n")

    lines.append("\n")
    replace_section(
        os.path.join(HERE, "README.md"),
        r"^<!-- REFS -->$",
        r"^<!-- /REFS -->$",
        lines,
    )


if __name__ == "__main__":
    main()

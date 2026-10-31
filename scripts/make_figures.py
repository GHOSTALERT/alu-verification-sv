"""Draw the README figures from results/summary.md (needs matplotlib).

    python3 scripts/make_figures.py   ->  docs/images/testbench.png, docs/images/regression.png
"""
import re
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "images"
OPS = ["ADD", "SUB", "AND", "OR", "XOR", "SHL", "SHR", "PASS"]
INK, BLUE, TEAL, RED, GREY, SLATE = "#1f2937", "#2563eb", "#0d9488", "#dc2626", "#94a3b8", "#475569"


def load_summary():
    rows = {}
    for line in (ROOT / "results" / "summary.md").read_text().splitlines():
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) == 15 and cells[1].isdigit():
            rows[cells[0]] = dict(zip(["run", "seed", "txns", "pass", "fail", "assert", "cov", *OPS], cells))
    return rows


def testbench():
    fig, ax = plt.subplots(figsize=(10, 4.2))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 44)
    ax.axis("off")

    def box(x, y, w, h, title, sub, color):
        ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.4,rounding_size=1.5",
                                    fc="white", ec=color, lw=2))
        ax.text(x + w / 2, y + h * 0.64, title, ha="center", va="center", fontsize=11, weight="bold", color=color)
        ax.text(x + w / 2, y + h * 0.3, sub, ha="center", va="center", fontsize=8, color=INK)

    def arrow(a, b, label="", color=INK):
        ax.add_patch(FancyArrowPatch(a, b, arrowstyle="-|>", mutation_scale=14, lw=1.6, color=color))
        if label:
            ax.text((a[0] + b[0]) / 2, (a[1] + b[1]) / 2 + 1.6, label, ha="center", fontsize=8, color=color)

    box(1, 26, 21, 12, "Transaction", "rand A, B, opcode\nrandom / boundary / max", BLUE)
    box(26, 26, 15, 12, "Driver", "drives alu_if,\nwaits 5 time units", BLUE)
    box(48, 26, 16, 12, "ALU (DUT)", "8 ops, 4-bit\n+define+INJECT_BUG", RED)
    box(71, 26, 15, 12, "Monitor", "samples settled\noutputs", BLUE)
    box(64, 4, 22, 13, "Scoreboard", "reference model,\nPASS / FAIL counts", TEAL)
    box(1, 2, 26, 10, "top_tb", "assertions · opcode coverage\nlog file · N transactions", SLATE)
    box(32, 2, 24, 10, "Regression", "run.tcl · regress.sh\nparse_logs.pl → summary.md", SLATE)
    arrow((23, 32), (25.5, 32))
    arrow((43, 32), (47.5, 32), "alu_if")
    arrow((66, 32), (70.5, 32))
    arrow((78.5, 25.5), (76, 18), "actual")
    arrow((14, 25.5), (63.5, 14), "expected (reference model)", TEAL)
    ax.text(50, 42, "Layered SystemVerilog testbench", ha="center", fontsize=13, weight="bold", color=INK)
    fig.savefig(OUT / "testbench.png", dpi=170, bbox_inches="tight", facecolor="white")


def regression(rows):
    clean = [r for k, r in rows.items() if k != "bug_injected"]
    bug = rows["bug_injected"]
    fig, axes = plt.subplots(1, 2, figsize=(11, 3.8), gridspec_kw={"width_ratios": [1.15, 1]})

    ax = axes[0]
    totals = [sum(int(r[o]) for r in clean) for o in OPS]
    ax.bar(OPS, totals, color=BLUE)
    for i, v in enumerate(totals):
        ax.text(i, v + 2, str(v), ha="center", fontsize=8)
    n = sum(int(r["txns"]) for r in clean)
    ax.set_title(f"Clean ALU: {n} transactions over {len(clean)} runs, 0 failures", fontsize=10, loc="left")
    ax.set_ylabel("transactions per opcode")

    ax = axes[1]
    fails = [0] * len(OPS)
    fails[OPS.index("SHL")] = int(bug["fail"])          # the injected fault turns shift-left into a rotate
    passes = [int(bug[o]) - f for o, f in zip(OPS, fails)]
    ax.bar(OPS, passes, color=GREY, label="pass")
    ax.bar(OPS, fails, bottom=passes, color=RED, label="fail (caught)")
    ax.set_title(f"Injected fault (SHL → rotate): {bug['fail']} of {bug['SHL']} SHL caught", fontsize=10, loc="left")
    ax.legend(frameon=False, fontsize=8)
    for a in axes:
        a.spines[["top", "right"]].set_visible(False)
        a.tick_params(labelsize=8)
    fig.tight_layout()
    fig.savefig(OUT / "regression.png", dpi=170, bbox_inches="tight", facecolor="white")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    testbench()
    regression(load_summary())
    print("wrote", OUT / "testbench.png", OUT / "regression.png")

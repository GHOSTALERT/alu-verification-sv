#!/usr/bin/env bash
# Regression: many seeds at the report's 20 transactions, one long run,
# and one run against the ALU with an injected fault. Every transcript
# lands in results/runs/, then parse_logs.pl writes results/summary.md.
#
#   bash scripts/regress.sh            # seeds 1..10
#   SEEDS="1 2 3" bash scripts/regress.sh
set -euo pipefail
cd "$(dirname "$0")/.."

command -v vsim >/dev/null || export PATH="$HOME/intelFPGA/20.1/modelsim_ase/bin:$PATH"

SEEDS=${SEEDS:-$(seq 1 10)}
OUT=results/runs
rm -rf "$OUT" && mkdir -p "$OUT" logs

compile() {   # $1 = extra vlog defines
    rm -rf work && vlib work >/dev/null
    vlog -sv $1 rtl/alu.sv >/dev/null
    vlog -sv +incdir+tb tb/top_tb.sv >/dev/null
}

sim() {       # $1 = name, $2 = seed, $3 = transactions
    vsim -c -sv_seed "$2" top_tb +NUM_TXN="$3" +LOG="$OUT/$1.sim.log" \
         -do "run -all; quit -f" > "$OUT/$1.transcript" 2>&1 || true
    echo "  $1: $(grep -h '^# SUMMARY' "$OUT/$1.transcript" | sed 's/^# //')"
}

echo "Clean ALU, 20 transactions per seed"
compile ""
for s in $SEEDS; do sim "seed_$s" "$s" 20; done

echo "Clean ALU, 1000 transactions"
sim long_1000 42 1000

echo "ALU with injected shift-left fault, 200 transactions"
compile "+define+INJECT_BUG"
sim bug_injected 42 200

rm -rf work
perl scripts/parse_logs.pl "$OUT" > results/summary.md
echo "Wrote results/summary.md"

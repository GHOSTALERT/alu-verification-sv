# How to run

```bash
git clone https://github.com/GHOSTALERT/alu-verification-sv.git
cd alu-verification-sv
```

## Requirements

- ModelSim, tested with ModelSim - Intel FPGA Starter Edition 2020.1 (free). Put its `bin` directory on `PATH`, for example:

  ```bash
  export PATH=~/intelFPGA/20.1/modelsim_ase/bin:$PATH
  ```

- Bash and Perl for the regression (`scripts/regress.sh`, `scripts/parse_logs.pl`)
- Python 3 with matplotlib, only to redraw the README figures

## The report's run

20 transactions, transcript in the console, log in `logs/sim.log`:

```bash
vsim -c -do scripts/run.tcl
```

Inside the ModelSim GUI instead: `do scripts/run.tcl`.

## Other seeds, more transactions, an injected fault

```bash
vsim -c -do "set SEED 7; set NUM_TXN 500; do scripts/run.tcl"
vsim -c -do "set BUG 1; set NUM_TXN 200; do scripts/run.tcl"     # ALU compiled with +define+INJECT_BUG
```

## Full regression

Writes `results/runs/*.transcript` and `results/summary.md`:

```bash
bash scripts/regress.sh
python3 scripts/make_figures.py      # redraw docs/images/*.png from results/summary.md
```

## Note on `randomize()`

ModelSim - Intel FPGA Starter Edition stops with a fatal error on `randomize()`, because the constraint solver needs a Questa licence. The transaction class keeps its `rand` fields and `valid_opcode` constraint for full simulators. `gen()` draws the values with `$urandom`, which honours `-sv_seed`.

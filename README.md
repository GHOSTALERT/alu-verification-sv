# Verification of a 4-bit ALU using Constrained-Random Testing in SystemVerilog

BEVD205L Scripting Languages & Verification project (Slot A2, Team 6). Team: Aditya Manoj (24BVD0070, group lead), Arrnav Trisal (24BVD0064), Gavin Fernandes (24BVD0083), Ashmit Singh (24BVD0027).

A 4-bit combinational ALU with eight operations is verified by a layered, object-oriented SystemVerilog testbench: transaction, driver, monitor and scoreboard classes, a reference model, immediate assertions, functional coverage per opcode and a log file. A TCL script runs the whole flow in ModelSim with one command.

The submitted report is in [`report/ALU_Verification_Final_Report.pdf`](report/ALU_Verification_Final_Report.pdf).
The team's original testbench and ModelSim transcript are in [`original/`](original/).

## DUT

| Opcode | Operation | Result |
|---|---|---|
| 000 | Addition | `A + B` (carry discarded) |
| 001 | Subtraction | `A - B` (mod 16) |
| 010 | AND | `A & B` |
| 011 | OR | `A \| B` |
| 100 | XOR | `A ^ B` |
| 101 | Shift left | `A << 1` |
| 110 | Shift right | `A >> 1` |
| 111 | Pass through | `A` |

## Testbench

| File | Role |
|---|---|
| `tb/interface.sv` | `alu_if`: A, B, opcode, result in one virtual interface |
| `tb/transaction.sv` | `rand` A, B, opcode with `valid_opcode` constraint; `gen()` picks one of three stimulus modes: random, boundary (A=0, B=15), maximum (A=15, B=15) |
| `tb/driver.sv` | Drives a transaction onto the interface, waits 5 time units |
| `tb/monitor.sv` | Samples the settled outputs and prints them |
| `tb/scoreboard.sv` | Reference model (`case` on opcode) and PASS/FAIL counters |
| `tb/top_tb.sv` | Instantiates everything, runs N transactions, immediate assertions, opcode and mode coverage, `$fopen`/`$fdisplay` log |
| `scripts/run.tcl` | `vdel` / `vlib` / `vlog` / `vsim` / `run -all` in one command |
| `scripts/regress.sh` | Multi-seed regression, long run and bug-injection run |
| `scripts/parse_logs.pl` | Perl parser that turns the transcripts into `results/summary.md` |

ModelSim - Intel FPGA Starter Edition stops with a fatal error on `randomize()` (the constraint solver needs a Questa licence). The transaction keeps its `rand` fields and constraint for full simulators, and `gen()` draws the values with `$urandom`, which honours `-sv_seed`. The original testbench did the same inline in `top_tb.sv`.

## Run it

Needs ModelSim (tested with ModelSim - Intel FPGA Starter Edition 2020.1).

```bash
cd ~/Downloads/aluVerifProj
export PATH=~/intelFPGA/20.1/modelsim_ase/bin:$PATH

# The report's run: 20 transactions, transcript in the console, log in logs/sim.log
vsim -c -do scripts/run.tcl
# Inside the ModelSim GUI instead:   do scripts/run.tcl

# Other seeds / more transactions / injected fault
vsim -c -do "set SEED 7; set NUM_TXN 500; do scripts/run.tcl"
vsim -c -do "set BUG 1; set NUM_TXN 200; do scripts/run.tcl"

# Full regression -> results/runs/*.transcript and results/summary.md
bash scripts/regress.sh
```

## Results

The report's run (April 2026): 20 transactions, 20 PASS, 0 errors, 0 warnings, 7 of 8 opcodes exercised (addition was not drawn).

Re-run with `scripts/regress.sh` ([`results/summary.md`](results/summary.md)):

| Run | Transactions | Pass | Fail | Opcode coverage |
|---|---|---|---|---|
| Seeds 1-10, 20 transactions each | 200 | 200 | 0 | 8/8 in 5 of 10 seeds |
| Seed 42, long run | 1000 | 1000 | 0 | 8/8 |
| Seed 42, ALU with injected shift-left fault | 200 | 183 | **17** | 8/8 |

- At 20 transactions, full opcode coverage depends on the seed. Half of the seeds miss at least one opcode, as the report's own run did. More transactions or several seeds close that gap.
- The bug-injection run compiles the ALU with `+define+INJECT_BUG`, which turns shift-left into a rotate. The scoreboard and the assertions both flag every transaction where the rotate differs from the shift (shift-left with A[3] = 1). 17 of the 34 shift-left transactions fail, for example `A=9 opcode=5`: expected 2, got 3.

## Layout

```
rtl/        alu.sv (DUT, optional INJECT_BUG)
tb/         interface, transaction, driver, monitor, scoreboard, top_tb
scripts/    run.tcl, regress.sh, parse_logs.pl
logs/       sim.log from the last run.tcl run
results/    runs/<name>.transcript and .sim.log, summary.md
original/   the team's testbench files and ModelSim transcript (17 Apr 2026)
report/     submitted report (PDF)
```

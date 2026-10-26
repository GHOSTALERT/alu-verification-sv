# One-command simulation flow for ModelSim / QuestaSim.
#
# From the project root, inside the ModelSim console:   do scripts/run.tcl
# Or from a shell:   vsim -c -do scripts/run.tcl
#
# Optional Tcl variables, set before sourcing:
#   set SEED 7        (default: 1)
#   set NUM_TXN 200   (default: 20)
#   set BUG 1         (compile the ALU with the injected shift-left fault)

if {![info exists SEED]}    { set SEED 1 }
if {![info exists NUM_TXN]} { set NUM_TXN 20 }
if {![info exists BUG]}     { set BUG 0 }

file mkdir logs
if {[file exists work]} { vdel -all }
vlib work

set defs {}
if {$BUG} { set defs +define+INJECT_BUG }

vlog -sv {*}$defs rtl/alu.sv
vlog -sv +incdir+tb tb/top_tb.sv

vsim -sv_seed $SEED top_tb +NUM_TXN=$NUM_TXN +LOG=logs/sim.log
run -all
quit -f

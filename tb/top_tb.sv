`include "interface.sv"
`include "transaction.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

// Top-level self-checking testbench.
//
// Plusargs:
//   +NUM_TXN=<n>     number of transactions (default 20, as in the report)
//   +LOG=<path>      per-transaction log file (default logs/sim.log)
// Seed the stimulus with vsim -sv_seed <n>.
module top_tb;

    alu_if vif();

    alu dut (
        .A      (vif.A),
        .B      (vif.B),
        .opcode (vif.opcode),
        .result (vif.result)
    );

    driver     drv;
    monitor    mon;
    scoreboard scb;

    // Functional coverage: how often each opcode and stimulus mode was hit
    int opcode_count[8];
    int mode_count[3];
    int assert_fail;

    int    num_txn;
    string log_path;
    int    logfile;

    initial begin
        if (!$value$plusargs("NUM_TXN=%d", num_txn)) num_txn  = 20;
        if (!$value$plusargs("LOG=%s",     log_path)) log_path = "logs/sim.log";

        drv = new(vif);
        mon = new(vif);
        scb = new();

        logfile = $fopen(log_path, "w");
        if (logfile == 0) $fatal(1, "cannot open log file %s", log_path);

        repeat (num_txn) begin
            transaction t;
            bit ok;

            t = new();
            t.gen();
            t.display();

            drv.drive(t);
            mon.observe();

            // Immediate assertions: a second, independent check of the DUT
            case (vif.opcode)
                3'b000: assert (vif.result == 4'(vif.A + vif.B)) else begin assert_fail++; $error("ADD mismatch");  end
                3'b001: assert (vif.result == 4'(vif.A - vif.B)) else begin assert_fail++; $error("SUB mismatch");  end
                3'b010: assert (vif.result == (vif.A & vif.B))   else begin assert_fail++; $error("AND mismatch");  end
                3'b011: assert (vif.result == (vif.A | vif.B))   else begin assert_fail++; $error("OR mismatch");   end
                3'b100: assert (vif.result == (vif.A ^ vif.B))   else begin assert_fail++; $error("XOR mismatch");  end
                3'b101: assert (vif.result == 4'(vif.A << 1))    else begin assert_fail++; $error("SHL mismatch");  end
                3'b110: assert (vif.result == (vif.A >> 1))      else begin assert_fail++; $error("SHR mismatch");  end
                3'b111: assert (vif.result == vif.A)             else begin assert_fail++; $error("PASS mismatch"); end
            endcase

            ok = scb.check(t, vif.result);

            $fdisplay(logfile, "A=%0d B=%0d opcode=%0d mode=%s result=%0d %s",
                      vif.A, vif.B, vif.opcode, t.mode.name(), vif.result,
                      ok ? "PASS" : "FAIL");

            opcode_count[t.opcode]++;
            mode_count[t.mode]++;
        end

        report();
        $fclose(logfile);
        $finish;
    end

    function void report();
        int hit;
        hit = 0;
        $display("\n--- COVERAGE REPORT ---");
        for (int i = 0; i < 8; i++) begin
            $display("Opcode %0d executed %0d times", i, opcode_count[i]);
            if (opcode_count[i] > 0) hit++;
        end
        $display("Mode RANDOM=%0d BOUNDARY=%0d MAXIMUM=%0d",
                 mode_count[0], mode_count[1], mode_count[2]);
        $display("SUMMARY: txns=%0d pass=%0d fail=%0d assert_fail=%0d opcode_cov=%0d/8",
                 num_txn, scb.pass_count, scb.fail_count, assert_fail, hit);
        $fdisplay(logfile, "SUMMARY: txns=%0d pass=%0d fail=%0d assert_fail=%0d opcode_cov=%0d/8",
                  num_txn, scb.pass_count, scb.fail_count, assert_fail, hit);
    endfunction

endmodule

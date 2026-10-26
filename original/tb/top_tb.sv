`include "interface.sv"
`include "transaction.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

module top_tb;

    // Interface
    alu_if vif();

    // DUT
    alu dut (
        .A(vif.A),
        .B(vif.B),
        .opcode(vif.opcode),
        .result(vif.result)
    );

    // Components
    driver drv;
    monitor mon;
    scoreboard scb;

    // Coverage counter
    int opcode_count[8];

    // 🔥 Log file handle
    int logfile;

    initial begin
        drv = new(vif);
        mon = new(vif);
        scb = new();

        // 🔥 Open log file
        logfile = $fopen("logs/sim.log", "w");

        repeat(20) begin
            transaction t;
            int mode;

            t = new();

            mode = $urandom % 3;

            if (mode == 0) begin
                t.A = $urandom % 16;
                t.B = $urandom % 16;
            end
            else if (mode == 1) begin
                t.A = 4'd0;
                t.B = 4'd15;
            end
            else begin
                t.A = 4'd15;
                t.B = 4'd15;
            end

            t.opcode = $urandom % 8;

            t.display();

            drv.drive(t);
            mon.observe();

            // Assertions
            case (vif.opcode)
                3'b000: assert(vif.result == (vif.A + vif.B));
                3'b001: assert(vif.result == (vif.A - vif.B));
                3'b010: assert(vif.result == (vif.A & vif.B));
                3'b011: assert(vif.result == (vif.A | vif.B));
                3'b100: assert(vif.result == (vif.A ^ vif.B));
                3'b101: assert(vif.result == (vif.A << 1));
                3'b110: assert(vif.result == (vif.A >> 1));
                3'b111: assert(vif.result == vif.A);
            endcase

            scb.check(t, vif.result);

            // 🔥 Write to log file
            $fdisplay(logfile,
                "A=%0d B=%0d opcode=%0d result=%0d",
                vif.A, vif.B, vif.opcode, vif.result);

            // Coverage
            opcode_count[t.opcode]++;
        end

        // Coverage report
        $display("\n--- COVERAGE REPORT ---");
        for (int i = 0; i < 8; i++) begin
            $display("Opcode %0d executed %0d times", i, opcode_count[i]);
        end

        // 🔥 Close log file
        $fclose(logfile);

        $finish;
    end

endmodule

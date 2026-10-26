
class scoreboard;

    // Reference model (expected output generator)
    function logic [3:0] reference_model(
        input logic [3:0] A,
        input logic [3:0] B,
        input logic [2:0] opcode
    );

        case(opcode)
            3'b000: return A + B;
            3'b001: return A - B;
            3'b010: return A & B;
            3'b011: return A | B;
            3'b100: return A ^ B;
            3'b101: return A << 1;
            3'b110: return A >> 1;
            3'b111: return A;
            default: return 0;
        endcase

    endfunction

    task check(transaction t, logic [3:0] dut_out);

        logic [3:0] expected;

        expected = reference_model(t.A, t.B, t.opcode);

        if (expected == dut_out)
            $display("PASS ✅");
        else
            $display("FAIL ❌ Expected=%0d Got=%0d", expected, dut_out);

    endtask

endclass

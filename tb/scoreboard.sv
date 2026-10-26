// Behavioural reference model plus PASS/FAIL bookkeeping.
class scoreboard;

    int pass_count;
    int fail_count;

    function logic [3:0] reference_model(
        input logic [3:0] A,
        input logic [3:0] B,
        input logic [2:0] opcode
    );
        case (opcode)
            3'b000: return A + B;   // Addition
            3'b001: return A - B;   // Subtraction
            3'b010: return A & B;   // AND
            3'b011: return A | B;   // OR
            3'b100: return A ^ B;   // XOR
            3'b101: return A << 1;  // Shift Left
            3'b110: return A >> 1;  // Shift Right
            3'b111: return A;       // Pass Through
            default: return 4'b0000;
        endcase
    endfunction

    // Returns 1 on a match so the caller can log the verdict.
    function bit check(transaction t, logic [3:0] dut_out);
        logic [3:0] expected;
        expected = reference_model(t.A, t.B, t.opcode);
        if (expected === dut_out) begin
            pass_count++;
            $display("PASS");
            return 1;
        end
        fail_count++;
        $display("FAIL: Expected=%0d Got=%0d", expected, dut_out);
        return 0;
    endfunction

endclass

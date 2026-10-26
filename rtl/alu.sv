// 4-bit combinational ALU (Device Under Test)
//
//   opcode  operation      result
//   000     Addition       A + B        (carry out discarded)
//   001     Subtraction    A - B        (modulo 16)
//   010     Bitwise AND    A & B
//   011     Bitwise OR     A | B
//   100     Bitwise XOR    A ^ B
//   101     Shift Left     A << 1       (MSB discarded)
//   110     Shift Right    A >> 1       (logical)
//   111     Pass Through   A
//
// Compile with +define+INJECT_BUG to plant a deliberate fault in the
// shift-left path (rotate instead of shift). The testbench must catch it.

module alu (
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [2:0] opcode,
    output logic [3:0] result
);

    always_comb begin
        case (opcode)
            3'b000: result = A + B;
            3'b001: result = A - B;
            3'b010: result = A & B;
            3'b011: result = A | B;
            3'b100: result = A ^ B;
`ifdef INJECT_BUG
            3'b101: result = {A[2:0], A[3]};
`else
            3'b101: result = A << 1;
`endif
            3'b110: result = A >> 1;
            3'b111: result = A;
            default: result = 4'b0000;
        endcase
    end

endmodule

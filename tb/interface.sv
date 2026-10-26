// Bundles every DUT signal so the testbench classes reach the DUT
// through a single virtual interface handle.
interface alu_if;

    logic [3:0] A;
    logic [3:0] B;
    logic [2:0] opcode;
    logic [3:0] result;

endinterface

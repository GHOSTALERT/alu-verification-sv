// One stimulus packet: two operands and an opcode.
//
// The fields are declared rand with a constraint so the class works with a
// full SystemVerilog solver (Questa, VCS, Xcelium). ModelSim - Intel FPGA
// Starter Edition aborts on randomize(), so gen() draws the same constrained
// values with $urandom, which every simulator supports and which follows
// the -sv_seed of the run.
class transaction;

    typedef enum int { RANDOM = 0, BOUNDARY = 1, MAXIMUM = 2 } mode_e;

    rand bit [3:0] A, B;
    rand bit [2:0] opcode;
    mode_e         mode;

    constraint valid_opcode { opcode inside {[0:7]}; }

    // Stimulus modes, each picked with probability 1/3:
    //   RANDOM   - A and B uniformly random
    //   BOUNDARY - A = 0,  B = 15
    //   MAXIMUM  - A = 15, B = 15
    function void gen();
        mode = mode_e'($urandom % 3);
        case (mode)
            RANDOM:   begin A = $urandom % 16; B = $urandom % 16; end
            BOUNDARY: begin A = 4'd0;          B = 4'd15;         end
            MAXIMUM:  begin A = 4'd15;         B = 4'd15;         end
        endcase
        opcode = $urandom % 8;
    endfunction

    function void display();
        $display("TRANSACTION: A=%0d B=%0d opcode=%0d", A, B, opcode);
    endfunction

endclass

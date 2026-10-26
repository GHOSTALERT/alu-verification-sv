class transaction;

    rand bit [3:0] A, B;
    rand bit [2:0] opcode;

    // Constraint (very important)
    constraint valid_opcode {
        opcode inside {[0:7]};
    }

    function void display();
        $display("TRANSACTION: A=%0d B=%0d opcode=%0d", A, B, opcode);
    endfunction

endclass

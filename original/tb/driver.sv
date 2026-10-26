
class driver;

    virtual alu_if vif;

    function new(virtual alu_if vif);
        this.vif = vif;
    endfunction

    task drive(transaction t);
        vif.A = t.A;
        vif.B = t.B;
        vif.opcode = t.opcode;

        #5; // wait for DUT to compute
    endtask

endclass


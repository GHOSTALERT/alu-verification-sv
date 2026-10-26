// Applies a transaction to the DUT pins through the virtual interface.
class driver;

    virtual alu_if vif;

    function new(virtual alu_if vif);
        this.vif = vif;
    endfunction

    task drive(transaction t);
        vif.A      = t.A;
        vif.B      = t.B;
        vif.opcode = t.opcode;
        #5; // let the combinational DUT settle
    endtask

endclass

// Passively samples the interface after the driver has applied a transaction.
class monitor;

    virtual alu_if vif;

    function new(virtual alu_if vif);
        this.vif = vif;
    endfunction

    task observe();
        #5;
        $display("MONITOR: A=%0d B=%0d opcode=%0d result=%0d",
                 vif.A, vif.B, vif.opcode, vif.result);
    endtask

endclass

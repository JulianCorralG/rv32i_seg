module data_memory_tb;
    logic DMWr;
    logic [2:0] DMCtrl;
    logic [31:0] Address, DataWr, DataRd;

    DataMemory dut (
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .Address_ALURes(Address),
        .DataWr(DataWr),
        .DataRd(DataRd)
    );

    initial begin
        $dumpfile("sim/data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);

        DMWr = 0; Address = 0; DataWr = 0; DMCtrl = 0; #10;

        // Write Word
        DMWr = 1; DMCtrl = 3'b010; Address = 100; DataWr = 32'h12345678; #10;
        DMWr = 0;

        // Read Word
        DMCtrl = 3'b010; Address = 100; #10;
        if (DataRd !== 32'h12345678) $error("Read Word failed");

        // Read Byte (LSB) -> 78
        DMCtrl = 3'b100; // LBU
        Address = 100; #10; // Offset 0
        if (DataRd !== 32'h78) $error("Read Byte failed");

        $display("DataMemory Testbench Completed");
        $finish;
    end
endmodule

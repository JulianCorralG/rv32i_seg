module regfile_tb;
    logic clk, RUWr;
    logic [4:0] Rs1, Rs2, Rd;
    logic [31:0] DataWr;
    logic [31:0] RURs1, RURs2;

    RegistersUnit dut (
        .clk(clk),
        .RUWr(RUWr),
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(Rd),
        .DataWr(DataWr),
        .RURs1(RURs1),
        .RURs2(RURs2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/regfile_tb.vcd");
        $dumpvars(0, regfile_tb);
        
        clk = 0; RUWr = 0; Rs1 = 0; Rs2 = 0; Rd = 0; DataWr = 0;
        #10;

        // Test Write to x1
        RUWr = 1; Rd = 1; DataWr = 32'hDEADBEEF; #10;
        RUWr = 0;
        
        // Read x1
        Rs1 = 1; #10;
        if (RURs1 !== 32'hDEADBEEF) $error("Read x1 failed");

        // Test Write to x0 (Should remain 0)
        RUWr = 1; Rd = 0; DataWr = 32'hFFFFFFFF; #10;
        RUWr = 0;

        // Read x0
        Rs1 = 0; #10;
        if (RURs1 !== 0) $error("x0 is not 0");

        $display("RegFile Testbench Completed");
        $finish;
    end
endmodule

module pc_tb;
    logic clk, reset;
    logic [31:0] NextPC;
    logic [31:0] PCOutput;

    PC dut (
        .clk(clk),
        .reset(reset),
        .NextPC(NextPC),
        .PCOutput(PCOutput)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/pc_tb.vcd");
        $dumpvars(0, pc_tb);

        clk = 0; reset = 1; NextPC = 0;
        #10;
        
        // Verificar Reset
        if (PCOutput !== 0) $error("Reset failed");
        reset = 0;

        // Verificar Carga
        NextPC = 32'h0000_0004; #10;
        if (PCOutput !== 32'h0000_0004) $error("PC Update failed");

        NextPC = 32'h0000_0010; #10;
        if (PCOutput !== 32'h0000_0010) $error("PC Update failed");

        $display("PC Testbench Completed");
        $finish;
    end
endmodule

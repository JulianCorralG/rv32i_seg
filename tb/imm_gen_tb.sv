module imm_gen_tb;
    logic [31:7] Instr;
    logic [2:0] ImmSrc;
    logic [31:0] ImmExt;

    ImmGen dut (
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    initial begin
        $dumpfile("sim/imm_gen_tb.vcd");
        $dumpvars(0, imm_gen_tb);

        // I-Type: ADDI x1, x0, -1 (0xFFF00093) -> Imm = -1
        // Instr[31:7] = 0xFFF00093 >> 7
        Instr = 32'hFFF00093 >> 7; 
        ImmSrc = 3'b000; #10;
        if (ImmExt !== -1) $error("I-Type failed");

        // S-Type: SW x1, 4(x2) -> Imm = 4
        // 00110010000100000010000000100011 -> 0x00110223
        // Instr = 0x00110223 >> 7
        // Simulamos bits manuales para S-Type (Imm=4)
        // Imm[11:5]=0, Imm[4:0]=4
        Instr = {7'b0000000, 5'b00000, 5'b00000, 3'b000, 5'b00100}; // Fake bits
        ImmSrc = 3'b001; #10;
        if (ImmExt !== 4) $error("S-Type failed");

        $display("ImmGen Testbench Completed");
        $finish;
    end
endmodule

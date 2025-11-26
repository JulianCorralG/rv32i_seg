module branch_unit_tb;
    logic signed [31:0] A, B;
    logic [4:0] BrOp;
    logic NextPCSrc;

    BranchUnit dut (
        .RURs1(A),
        .RURs2(B),
        .BrOp(BrOp),
        .NextPCSrc(NextPCSrc)
    );

    initial begin
        $dumpfile("sim/branch_unit_tb.vcd");
        $dumpvars(0, branch_unit_tb);

        // BEQ (Funct3 = 000), BrOp[3]=1 (Branch)
        BrOp = {1'b0, 1'b1, 3'b000}; 
        A = 10; B = 10; #10;
        if (NextPCSrc !== 1) $error("BEQ Taken failed");

        A = 10; B = 20; #10;
        if (NextPCSrc !== 0) $error("BEQ Not Taken failed");

        // JUMP (BrOp[4]=1)
        BrOp = {1'b1, 1'b0, 3'b000}; #10;
        if (NextPCSrc !== 1) $error("JUMP failed");

        $display("BranchUnit Testbench Completed");
        $finish;
    end
endmodule

module alu_tb;
    logic signed [31:0] A, B;
    logic [3:0] ALUOp;
    logic signed [31:0] ALURes;

    ALU dut (
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .ALURes(ALURes)
    );

    initial begin
        $dumpfile("sim/alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // Test ADD
        A = 10; B = 5; ALUOp = 4'b0000; #10;
        if (ALURes !== 15) $error("ADD failed: 10 + 5 = %d", ALURes);

        // Test SUB
        A = 10; B = 5; ALUOp = 4'b1000; #10;
        if (ALURes !== 5) $error("SUB failed: 10 - 5 = %d", ALURes);

        // Test AND
        A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; ALUOp = 4'b0111; #10;
        if (ALURes !== 32'h00000000) $error("AND failed");

        // Test OR
        A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; ALUOp = 4'b0110; #10;
        if (ALURes !== 32'hFFFFFFFF) $error("OR failed");

        // Test SLT
        A = 10; B = 20; ALUOp = 4'b0010; #10;
        if (ALURes !== 1) $error("SLT failed: 10 < 20");
        
        A = 20; B = 10; ALUOp = 4'b0010; #10;
        if (ALURes !== 0) $error("SLT failed: 20 < 10");

        $display("ALU Testbench Completed");
        $finish;
    end
endmodule

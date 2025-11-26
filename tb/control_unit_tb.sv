module control_unit_tb;
    logic [6:0] OpCode, Funct7;
    logic [2:0] Funct3;
    logic RUWr, ALUASrc, ALUBSrc, DMWr;
    logic [1:0] RUDataWrSrc;
    logic [2:0] ImmSrc, DMCtrl;
    logic [3:0] ALUOp;
    logic [4:0] BrOp;

    ControlUnit dut (.*); // Conexión automática por nombre

    initial begin
        $dumpfile("sim/control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);

        // R-Type ADD
        OpCode = 7'b0110011; Funct3 = 3'b000; Funct7 = 7'b0000000; #10;
        if (RUWr !== 1 || ALUOp !== 4'b0000) $error("R-Type ADD failed");

        // I-Type ADDI
        OpCode = 7'b0010011; Funct3 = 3'b000; #10;
        if (ALUBSrc !== 1 || ImmSrc !== 3'b000) $error("I-Type ADDI failed");

        // Load LW
        OpCode = 7'b0000011; Funct3 = 3'b010; #10;
        if (RUDataWrSrc !== 2'b01) $error("LW failed");

        // Store SW
        OpCode = 7'b0100011; Funct3 = 3'b010; #10;
        if (DMWr !== 1) $error("SW failed");

        // Branch BEQ
        OpCode = 7'b1100011; Funct3 = 3'b000; #10;
        if (BrOp[3] !== 1) $error("Branch BEQ failed");

        $display("ControlUnit Testbench Completed");
        $finish;
    end
endmodule

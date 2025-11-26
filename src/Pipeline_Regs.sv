module IF_ID_Reg (
    input logic clk,
    input logic reset,
    input logic en, // Enable for stalling (Hazard Unit)
    input logic clr, // Flush for branching
    input logic [31:0] PC_F,
    input logic [31:0] Instr_F,
    input logic [31:0] PCPlus4_F,
    output logic [31:0] PC_D,
    output logic [31:0] Instr_D,
    output logic [31:0] PCPlus4_D
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_D <= 0;
            Instr_D <= 0;
            PCPlus4_D <= 0;
        end else if (clr) begin
            PC_D <= 0;
            Instr_D <= 0;
            PCPlus4_D <= 0;
        end else if (en) begin
            PC_D <= PC_F;
            Instr_D <= Instr_F;
            PCPlus4_D <= PCPlus4_F;
        end
    end
endmodule

module ID_EX_Reg (
    input logic clk,
    input logic reset,
    input logic clr, // Flush for branching
    // Control Signals
    input logic RUWr_D,
    input logic [1:0] RUDataWrSrc_D,
    input logic DMWr_D,
    input logic [2:0] DMCtrl_D,
    input logic ALUASrc_D,
    input logic ALUBSrc_D,
    input logic [3:0] ALUOp_D,
    input logic [4:0] BrOp_D, // Passed to EX for branch resolution
    // Data
    input logic [31:0] PC_D,
    input logic [31:0] RD1_D,
    input logic [31:0] RD2_D,
    input logic [31:0] ImmExt_D,
    input logic [31:0] PCPlus4_D,
    input logic [4:0] Rs1_D,
    input logic [4:0] Rs2_D,
    input logic [4:0] Rd_D,
    
    // Outputs
    output logic RUWr_E,
    output logic [1:0] RUDataWrSrc_E,
    output logic DMWr_E,
    output logic [2:0] DMCtrl_E,
    output logic ALUASrc_E,
    output logic ALUBSrc_E,
    output logic [3:0] ALUOp_E,
    output logic [4:0] BrOp_E,
    
    output logic [31:0] PC_E,
    output logic [31:0] RD1_E,
    output logic [31:0] RD2_E,
    output logic [31:0] ImmExt_E,
    output logic [31:0] PCPlus4_E,
    output logic [4:0] Rs1_E,
    output logic [4:0] Rs2_E,
    output logic [4:0] Rd_E
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset || clr) begin
            RUWr_E <= 0;
            RUDataWrSrc_E <= 0;
            DMWr_E <= 0;
            DMCtrl_E <= 0;
            ALUASrc_E <= 0;
            ALUBSrc_E <= 0;
            ALUOp_E <= 0;
            BrOp_E <= 0;
            PC_E <= 0;
            RD1_E <= 0;
            RD2_E <= 0;
            ImmExt_E <= 0;
            PCPlus4_E <= 0;
            Rs1_E <= 0;
            Rs2_E <= 0;
            Rd_E <= 0;
        end else begin
            RUWr_E <= RUWr_D;
            RUDataWrSrc_E <= RUDataWrSrc_D;
            DMWr_E <= DMWr_D;
            DMCtrl_E <= DMCtrl_D;
            ALUASrc_E <= ALUASrc_D;
            ALUBSrc_E <= ALUBSrc_D;
            ALUOp_E <= ALUOp_D;
            BrOp_E <= BrOp_D;
            PC_E <= PC_D;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            ImmExt_E <= ImmExt_D;
            PCPlus4_E <= PCPlus4_D;
            Rs1_E <= Rs1_D;
            Rs2_E <= Rs2_D;
            Rd_E <= Rd_D;
        end
    end
endmodule

module EX_MEM_Reg (
    input logic clk,
    input logic reset,
    // Control Signals
    input logic RUWr_E,
    input logic [1:0] RUDataWrSrc_E,
    input logic DMWr_E,
    input logic [2:0] DMCtrl_E,
    // Data
    input logic [31:0] ALUResult_E,
    input logic [31:0] WriteData_E, // RD2 forwarded
    input logic [31:0] PCPlus4_E,
    input logic [4:0] Rd_E,
    
    // Outputs
    output logic RUWr_M,
    output logic [1:0] RUDataWrSrc_M,
    output logic DMWr_M,
    output logic [2:0] DMCtrl_M,
    
    output logic [31:0] ALUResult_M,
    output logic [31:0] WriteData_M,
    output logic [31:0] PCPlus4_M,
    output logic [4:0] Rd_M
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            RUWr_M <= 0;
            RUDataWrSrc_M <= 0;
            DMWr_M <= 0;
            DMCtrl_M <= 0;
            ALUResult_M <= 0;
            WriteData_M <= 0;
            PCPlus4_M <= 0;
            Rd_M <= 0;
        end else begin
            RUWr_M <= RUWr_E;
            RUDataWrSrc_M <= RUDataWrSrc_E;
            DMWr_M <= DMWr_E;
            DMCtrl_M <= DMCtrl_E;
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            PCPlus4_M <= PCPlus4_E;
            Rd_M <= Rd_E;
        end
    end
endmodule

module MEM_WB_Reg (
    input logic clk,
    input logic reset,
    // Control Signals
    input logic RUWr_M,
    input logic [1:0] RUDataWrSrc_M,
    // Data
    input logic [31:0] ALUResult_M,
    input logic [31:0] ReadData_M,
    input logic [31:0] PCPlus4_M,
    input logic [4:0] Rd_M,
    
    // Outputs
    output logic RUWr_W,
    output logic [1:0] RUDataWrSrc_W,
    
    output logic [31:0] ALUResult_W,
    output logic [31:0] ReadData_W,
    output logic [31:0] PCPlus4_W,
    output logic [4:0] Rd_W
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            RUWr_W <= 0;
            RUDataWrSrc_W <= 0;
            ALUResult_W <= 0;
            ReadData_W <= 0;
            PCPlus4_W <= 0;
            Rd_W <= 0;
        end else begin
            RUWr_W <= RUWr_M;
            RUDataWrSrc_W <= RUDataWrSrc_M;
            ALUResult_W <= ALUResult_M;
            ReadData_W <= ReadData_M;
            PCPlus4_W <= PCPlus4_M;
            Rd_W <= Rd_M;
        end
    end
endmodule

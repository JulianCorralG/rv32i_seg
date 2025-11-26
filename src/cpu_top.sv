module cpu_top (
    input logic clk,
    input logic reset,
    output logic [31:0] WriteData, // Para verificar escritura en memoria/reg
    output logic [31:0] DataAdr    // Para verificar dirección de memoria
);

    // ========================================================================
    // Internal Signals for Pipeline Stages
    // ========================================================================

    // --- IF Stage Signals ---
    logic [31:0] PC_F, PC_Next_F, PCPlus4_F;
    logic [31:0] Instr_F;
    logic        Stall_F; // From Hazard Unit

    // --- ID Stage Signals ---
    logic [31:0] PC_D, Instr_D, PCPlus4_D;
    logic [31:0] RD1_D, RD2_D, ImmExt_D;
    logic [4:0]  Rs1_D, Rs2_D, Rd_D;
    logic        Stall_D; // From Hazard Unit
    logic        Flush_D; // For Branching (PCSrc_E)
    
    // Control Signals ID
    logic       RUWr_D, ALUASrc_D, ALUBSrc_D, DMWr_D;
    logic [1:0] RUDataWrSrc_D;
    logic [2:0] ImmSrc_D, DMCtrl_D;
    logic [3:0] ALUOp_D;
    logic [4:0] BrOp_D;
    logic       Flush_E_Hazard; // From Hazard Unit

    // --- EX Stage Signals ---
    logic [31:0] PC_E, RD1_E, RD2_E, ImmExt_E, PCPlus4_E;
    logic [4:0]  Rs1_E, Rs2_E, Rd_E;
    logic [31:0] SrcA_E, SrcB_E; // ALU Inputs
    logic [31:0] WriteData_E; // Data to be written to memory (RD2 forwarded)
    logic [31:0] ALUResult_E;
    logic        PCSrc_E; // Branch decision result
    logic [31:0] PCTarget_E;
    
    // Control Signals EX
    logic       RUWr_E, ALUASrc_E, ALUBSrc_E, DMWr_E;
    logic [1:0] RUDataWrSrc_E;
    logic [2:0] DMCtrl_E;
    logic [3:0] ALUOp_E;
    logic [4:0] BrOp_E;
    
    // Forwarding Signals
    logic [1:0] ForwardAE, ForwardBE;
    logic [31:0] SrcA_Forwarded, SrcB_Forwarded;

    // --- MEM Stage Signals ---
    logic [31:0] ALUResult_M, WriteData_M, PCPlus4_M;
    logic [4:0]  Rd_M;
    logic [31:0] ReadData_M;
    
    // Control Signals MEM
    logic       RUWr_M, DMWr_M;
    logic [1:0] RUDataWrSrc_M;
    logic [2:0] DMCtrl_M;

    // --- WB Stage Signals ---
    logic [31:0] ALUResult_W, ReadData_W, PCPlus4_W, Result_W;
    logic [4:0]  Rd_W;
    
    // Control Signals WB
    logic       RUWr_W;
    logic [1:0] RUDataWrSrc_W;


    // ========================================================================
    // 1. Fetch Stage (IF)
    // ========================================================================

    // Mux for Next PC (Branching)
    // PCSrc_E comes from EX stage
    Mux2 #(32) pcmux (
        .sel(PCSrc_E),
        .a(PCPlus4_F),
        .b(PCTarget_E),
        .y(PC_Next_F)
    );

    // Program Counter
    // Enable controlled by Stall_F (Active Low) -> !Stall_F means Enable
    PC pc_module (
        .clk(clk),
        .reset(reset),
        .NextPC(PC_Next_F),
        .En(Stall_F), // Stall_F is active low enable from Hazard Unit
        .PCOutput(PC_F)
    );

    // Adder PC + 4
    Adder pc_plus4_adder (
        .PCOutput(PC_F),
        .AdderOutput(PCPlus4_F)
    );

    // Instruction Memory
    InstructionMemory instr_mem (
        .Address_PC(PC_F),
        .Instruction(Instr_F)
    );

    // IF/ID Pipeline Register
    IF_ID_Reg if_id_reg (
        .clk(clk),
        .reset(reset),
        .en(Stall_D), // Stall_D is active low enable from Hazard Unit
        .clr(PCSrc_E), // Flush on branch taken
        .PC_F(PC_F),
        .Instr_F(Instr_F),
        .PCPlus4_F(PCPlus4_F),
        .PC_D(PC_D),
        .Instr_D(Instr_D),
        .PCPlus4_D(PCPlus4_D)
    );

    // ========================================================================
    // 2. Decode Stage (ID)
    // ========================================================================
    
    assign Rs1_D = Instr_D[19:15];
    assign Rs2_D = Instr_D[24:20];
    assign Rd_D  = Instr_D[11:7];
    
    // Control Unit
    ControlUnit control_unit (
        .OpCode(Instr_D[6:0]),
        .Funct7(Instr_D[31:25]),
        .Funct3(Instr_D[14:12]),
        .RUWr(RUWr_D),
        .ALUASrc(ALUASrc_D),
        .ALUBSrc(ALUBSrc_D),
        .DMWr(DMWr_D),
        .RUDataWrSrc(RUDataWrSrc_D),
        .ImmSrc(ImmSrc_D),
        .DMCtrl(DMCtrl_D),
        .ALUOp(ALUOp_D),
        .BrOp(BrOp_D)
    );

    // Register Unit
    // Writes happen in WB stage (Result_W, Rd_W, RUWr_W)
    RegistersUnit reg_unit (
        .clk(clk),
        .RUWr(RUWr_W),
        .Rs1(Rs1_D),
        .Rs2(Rs2_D),
        .Rd(Rd_W),
        .DataWr(Result_W),
        .RURs1(RD1_D),
        .RURs2(RD2_D)
    );

    // Immediate Generator
    ImmGen imm_gen (
        .Instr(Instr_D[31:7]),
        .ImmSrc(ImmSrc_D),
        .ImmExt(ImmExt_D)
    );

    // Hazard Unit
    HazardUnit hazard_unit (
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .Rd_E(Rd_E),
        .RUDataWrSrc_E(RUDataWrSrc_E),
        .Stall_F(Stall_F),
        .Stall_D(Stall_D),
        .Flush_E(Flush_E_Hazard),
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .Rd_M(Rd_M),
        .RUWr_M(RUWr_M),
        .Rd_W(Rd_W),
        .RUWr_W(RUWr_W),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

    // ID/EX Pipeline Register
    // Flush if Branch Taken (PCSrc_E) OR Load-Use Hazard (Flush_E_Hazard)
    ID_EX_Reg id_ex_reg (
        .clk(clk),
        .reset(reset),
        .clr(PCSrc_E | Flush_E_Hazard), 
        .RUWr_D(RUWr_D),
        .RUDataWrSrc_D(RUDataWrSrc_D),
        .DMWr_D(DMWr_D),
        .DMCtrl_D(DMCtrl_D),
        .ALUASrc_D(ALUASrc_D),
        .ALUBSrc_D(ALUBSrc_D),
        .ALUOp_D(ALUOp_D),
        .BrOp_D(BrOp_D),
        .PC_D(PC_D),
        .RD1_D(RD1_D),
        .RD2_D(RD2_D),
        .ImmExt_D(ImmExt_D),
        .PCPlus4_D(PCPlus4_D),
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .Rd_D(Rd_D),
        
        .RUWr_E(RUWr_E),
        .RUDataWrSrc_E(RUDataWrSrc_E),
        .DMWr_E(DMWr_E),
        .DMCtrl_E(DMCtrl_E),
        .ALUASrc_E(ALUASrc_E),
        .ALUBSrc_E(ALUBSrc_E),
        .ALUOp_E(ALUOp_E),
        .BrOp_E(BrOp_E),
        .PC_E(PC_E),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .ImmExt_E(ImmExt_E),
        .PCPlus4_E(PCPlus4_E),
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .Rd_E(Rd_E)
    );

    // ========================================================================
    // 3. Execution Stage (EX)
    // ========================================================================

    // Forwarding Muxes
    Mux3 #(32) forward_a_mux (
        .sel(ForwardAE),
        .a(RD1_E),
        .b(Result_W), // Forward from WB
        .c(ALUResult_M), // Forward from MEM
        .y(SrcA_Forwarded)
    );

    Mux3 #(32) forward_b_mux (
        .sel(ForwardBE),
        .a(RD2_E),
        .b(Result_W), // Forward from WB
        .c(ALUResult_M), // Forward from MEM
        .y(SrcB_Forwarded)
    );
    
    assign WriteData_E = SrcB_Forwarded; // Data to store in memory (if Store instr)

    // ALU Source Muxes
    Mux2 #(32) srca_mux (
        .sel(ALUASrc_E),
        .a(SrcA_Forwarded),
        .b(PC_E),
        .y(SrcA_E)
    );

    Mux2 #(32) srcb_mux (
        .sel(ALUBSrc_E),
        .a(SrcB_Forwarded),
        .b(ImmExt_E),
        .y(SrcB_E)
    );

    // ALU
    ALU alu (
        .A(SrcA_E),
        .B(SrcB_E),
        .ALUOp(ALUOp_E),
        .ALURes(ALUResult_E)
    );
    
    // Branch Unit
    // Uses Forwarded operands for comparison
    BranchUnit branch_unit (
        .RURs1(SrcA_Forwarded),
        .RURs2(SrcB_Forwarded),
        .BrOp(BrOp_E),
        .NextPCSrc(PCSrc_E)
    );
    
    // Target Address Calculation (PC + Imm)
    assign PCTarget_E = PC_E + ImmExt_E;

    // EX/MEM Pipeline Register
    EX_MEM_Reg ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .RUWr_E(RUWr_E),
        .RUDataWrSrc_E(RUDataWrSrc_E),
        .DMWr_E(DMWr_E),
        .DMCtrl_E(DMCtrl_E),
        .ALUResult_E(ALUResult_E),
        .WriteData_E(WriteData_E),
        .PCPlus4_E(PCPlus4_E),
        .Rd_E(Rd_E),
        
        .RUWr_M(RUWr_M),
        .RUDataWrSrc_M(RUDataWrSrc_M),
        .DMWr_M(DMWr_M),
        .DMCtrl_M(DMCtrl_M),
        .ALUResult_M(ALUResult_M),
        .WriteData_M(WriteData_M),
        .PCPlus4_M(PCPlus4_M),
        .Rd_M(Rd_M)
    );

    // ========================================================================
    // 4. Memory Stage (MEM)
    // ========================================================================

    // Data Memory
    DataMemory data_mem (
        .DMWr(DMWr_M),
        .DMCtrl(DMCtrl_M),
        .Address_ALURes(ALUResult_M),
        .DataWr(WriteData_M),
        .DataRd(ReadData_M)
    );

    // MEM/WB Pipeline Register
    MEM_WB_Reg mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .RUWr_M(RUWr_M),
        .RUDataWrSrc_M(RUDataWrSrc_M),
        .ALUResult_M(ALUResult_M),
        .ReadData_M(ReadData_M),
        .PCPlus4_M(PCPlus4_M),
        .Rd_M(Rd_M),
        
        .RUWr_W(RUWr_W),
        .RUDataWrSrc_W(RUDataWrSrc_W),
        .ALUResult_W(ALUResult_W),
        .ReadData_W(ReadData_W),
        .PCPlus4_W(PCPlus4_W),
        .Rd_W(Rd_W)
    );

    // ========================================================================
    // 5. Write Back Stage (WB)
    // ========================================================================

    // Write Back Mux
    Mux3 #(32) result_mux (
        .sel(RUDataWrSrc_W),
        .a(ALUResult_W),
        .b(ReadData_W),
        .c(PCPlus4_W),
        .y(Result_W)
    );

    // Salidas de depuración
    assign WriteData = Result_W;
    assign DataAdr = ALUResult_M;

endmodule

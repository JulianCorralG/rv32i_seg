module cpu_top (
    input logic clk,
    input logic reset,
    output logic [31:0] WriteData, // Para verificar escritura en memoria/reg
    output logic [31:0] DataAdr    // Para verificar dirección de memoria
);

    // Señales de interconexión
    logic [31:0] PC_Next, PC_Current, PC_Plus4;
    logic [31:0] Instr;
    logic [31:0] ALUResult, SrcA, SrcB;
    logic [31:0] RD1, RD2;
    logic [31:0] ImmExt;
    logic [31:0] ReadData;
    logic [31:0] Result; // Dato a escribir en el banco de registros

    // Señales de Control
    logic       RUWr, ALUASrc, ALUBSrc, DMWr;
    logic [1:0] RUDataWrSrc;
    logic [2:0] ImmSrc, DMCtrl;
    logic [3:0] ALUOp;
    logic [4:0] BrOp;
    logic       PCSrc;

    // 1. Program Counter
    PC pc_module (
        .clk(clk),
        .reset(reset),
        .NextPC(PC_Next),
        .PCOutput(PC_Current)
    );

    // 2. Adder PC + 4
    Adder pc_plus4_adder (
        .PCOutput(PC_Current),
        .AdderOutput(PC_Plus4)
    );

    // 3. Instruction Memory
    InstructionMemory instr_mem (
        .Address_PC(PC_Current),
        .Instruction(Instr)
    );

    // 4. Control Unit
    ControlUnit control_unit (
        .OpCode(Instr[6:0]),
        .Funct7(Instr[31:25]),
        .Funct3(Instr[14:12]),
        .RUWr(RUWr),
        .ALUASrc(ALUASrc),
        .ALUBSrc(ALUBSrc),
        .DMWr(DMWr),
        .RUDataWrSrc(RUDataWrSrc),
        .ImmSrc(ImmSrc),
        .DMCtrl(DMCtrl),
        .ALUOp(ALUOp),
        .BrOp(BrOp)
    );

    // 5. Register Unit
    RegistersUnit reg_unit (
        .clk(clk),
        .RUWr(RUWr),
        .Rs1(Instr[19:15]),
        .Rs2(Instr[24:20]),
        .Rd(Instr[11:7]),
        .DataWr(Result),
        .RURs1(RD1),
        .RURs2(RD2)
    );

    // 6. Immediate Generator
    ImmGen imm_gen (
        .Instr(Instr[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // 7. Muxes para ALU
    Mux2 #(32) srca_mux (
        .sel(ALUASrc),
        .a(RD1),
        .b(PC_Current),
        .y(SrcA)
    );

    Mux2 #(32) srcb_mux (
        .sel(ALUBSrc),
        .a(RD2),
        .b(ImmExt),
        .y(SrcB)
    );

    // 8. ALU
    ALU alu (
        .A(SrcA),
        .B(SrcB),
        .ALUOp(ALUOp),
        .ALURes(ALUResult)
    );

    // 9. Data Memory
    DataMemory data_mem (
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .Address_ALURes(ALUResult),
        .DataWr(RD2),
        .DataRd(ReadData)
    );

    // 10. Write Back Mux
    Mux3 #(32) result_mux (
        .sel(RUDataWrSrc),
        .a(ALUResult),
        .b(ReadData),
        .c(PC_Plus4),
        .y(Result)
    );

    // 11. Branch Unit
    BranchUnit branch_unit (
        .RURs1(RD1),
        .RURs2(RD2),
        .BrOp(BrOp),
        .NextPCSrc(PCSrc)
    );

    // 12. Next PC Mux
    Mux2 #(32) pcmux (
        .sel(PCSrc),
        .a(PC_Plus4),
        .b(ALUResult),
        .y(PC_Next)
    );

    // Salidas de depuración
    assign WriteData = Result;
    assign DataAdr = ALUResult;

endmodule

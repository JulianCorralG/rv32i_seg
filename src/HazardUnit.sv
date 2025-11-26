module HazardUnit (
    // Hazard Detection Unit Signals
    input logic [4:0] Rs1_D,
    input logic [4:0] Rs2_D,
    input logic [4:0] Rd_E,
    input logic [1:0] RUDataWrSrc_E, // To check if instruction in EX is a Load (01 for Mem Read)
    
    output logic Stall_F, // PCWrite
    output logic Stall_D, // IF/ID Write
    output logic Flush_E, // Control Mux (0 to flush)
    
    // Forwarding Unit Signals
    input logic [4:0] Rs1_E,
    input logic [4:0] Rs2_E,
    input logic [4:0] Rd_M,
    input logic RUWr_M,
    input logic [4:0] Rd_W,
    input logic RUWr_W,
    
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE
);

    // Hazard Detection Unit Logic
    // Detect Load-Use Hazard
    // If (ID/EX.MemRead and ((ID/EX.rd == IF/ID.rs1) or (ID/EX.rd == IF/ID.rs2)))
    // RUDataWrSrc_E == 2'b01 indicates reading from Data Memory (Load)
    
    logic lwStall;
    
    always_comb begin
        lwStall = 0;
        if ((RUDataWrSrc_E == 2'b01) && ((Rd_E == Rs1_D) || (Rd_E == Rs2_D))) begin
            lwStall = 1;
        end
        
        Stall_F = !lwStall; // Active Low enable for PC
        Stall_D = !lwStall; // Active Low enable for IF/ID
        Flush_E = lwStall;  // Active High flush for ID/EX (Control Mux)
    end

    // Forwarding Unit Logic
    // Forwarding to ALU Input A
    always_comb begin
        ForwardAE = 2'b00; // Default: No forwarding (use Register File output)
        
        // EX Hazard (Forward from MEM stage)
        if (RUWr_M && (Rd_M != 0) && (Rd_M == Rs1_E)) begin
            ForwardAE = 2'b10;
        end
        // MEM Hazard (Forward from WB stage)
        else if (RUWr_W && (Rd_W != 0) && (Rd_W == Rs1_E)) begin
            ForwardAE = 2'b01;
        end
    end
    
    // Forwarding to ALU Input B
    always_comb begin
        ForwardBE = 2'b00; // Default: No forwarding (use Register File output)
        
        // EX Hazard (Forward from MEM stage)
        if (RUWr_M && (Rd_M != 0) && (Rd_M == Rs2_E)) begin
            ForwardBE = 2'b10;
        end
        // MEM Hazard (Forward from WB stage)
        else if (RUWr_W && (Rd_W != 0) && (Rd_W == Rs2_E)) begin
            ForwardBE = 2'b01;
        end
    end

endmodule

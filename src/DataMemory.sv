module DataMemory (
    input logic DMWr,
    input logic [2:0] DMCtrl,
    input logic [31:0] Address_ALURes, DataWr,

    output logic [31:0] DataRd
);

    // 1. Declaración del Banco de Memoria
    localparam MEM_SIZE_WORDS = 1024; 
    logic [31:0] mem [MEM_SIZE_WORDS-1:0];

    // Variables para el indexado de la dirección
    // Usamos bits [11:2] para indexar 1024 palabras
    logic [9:0] word_addr;  
    logic [1:0] byte_offset;

    // Decodificación de dirección combinacional
    assign word_addr   = Address_ALURes[11:2]; 
    assign byte_offset = Address_ALURes[1:0];

    // ------------------------------------------------------------------
    // 2. Lógica de ESCRITURA (Asíncrona controlada por nivel DMWr)
    // Usamos always @* para modelar la escritura controlada por el nivel DMWr
    // dentro del mismo ciclo.
    // ------------------------------------------------------------------

    always @* begin
        // La memoria solo se actualiza si DMWr está activa
        if (DMWr) begin 
            // La lógica de control DMCtrl debe estar configurada para una operación Store (OpCodes 0100011)

            case (DMCtrl)
                3'b010: // SW (Store Word): Escribe los 32 bits completos
                    mem[word_addr] = DataWr; // = para evitar latch inferido
                    
                3'b001: // SH (Store Halfword): Escribe 16 bits (DataWr[15:0])
                    if (byte_offset[1] == 1'b0) // Halfword Inferior (offset 0x0, 0x1)
                        mem[word_addr][15:0] = DataWr[15:0];
                    else // Halfword Superior (offset 0x2, 0x3)
                        mem[word_addr][31:16] = DataWr[15:0];
                        
                3'b000: // SB (Store Byte): Escribe 8 bits (DataWr[7:0])
                    case (byte_offset)
                        2'b00: mem[word_addr][7:0]   = DataWr[7:0];   // Byte 0
                        2'b01: mem[word_addr][15:8]  = DataWr[7:0];   // Byte 1
                        2'b10: mem[word_addr][23:16] = DataWr[7:0];   // Byte 2
                        2'b11: mem[word_addr][31:24] = DataWr[7:0];   // Byte 3
                    endcase
                    
                default: ; // No hay escritura si DMCtrl no es un código de Store
            endcase
        end
    end

    // ------------------------------------------------------------------
    // 3. Lógica de LECTURA (Combinacional/Asíncrona)
    // ------------------------------------------------------------------

    always_comb begin
        logic [31:0] read_word;
        read_word = mem[word_addr];
        DataRd = 32'h00000000; // Valor por defecto

        // La lectura (Load) se selecciona por DMCtrl (OpCodes 0000011)
        case (DMCtrl)
            3'b000: // LB (Load Byte - con signo)
                case (byte_offset)
                    2'b00: DataRd = {{24{read_word[7]}},   read_word[7:0]};   // Byte 0
                    2'b01: DataRd = {{24{read_word[15]}},  read_word[15:8]};  // Byte 1
                    2'b10: DataRd = {{24{read_word[23]}},  read_word[23:16]}; // Byte 2
                    2'b11: DataRd = {{24{read_word[31]}},  read_word[31:24]}; // Byte 3
                    default: DataRd = 32'h00000000;
                endcase

            3'b001: // LH (Load Halfword - con signo)
                if (byte_offset[1] == 1'b0) // Halfword inferior (0 o 1)
                    DataRd = {{16{read_word[15]}}, read_word[15:0]}; // Extensión de Signo
                else // Halfword superior (2 o 3)
                    DataRd = {{16{read_word[31]}}, read_word[31:16]}; 

            3'b010: // LW (Load Word): Lee los 32 bits
                DataRd = read_word;
                    
            
                
            3'b011: // LHU (Load Halfword - sin signo)
                if (byte_offset[1] == 1'b0) // Halfword inferior
                    DataRd = {16'h0000, read_word[15:0]}; // Extensión a Cero
                else // Halfword superior
                    DataRd = {16'h0000, read_word[31:16]}; 
                    
            3'b100: // LBU (Load Byte - sin signo)
                case (byte_offset)
                    2'b00: DataRd = {24'h000000, read_word[7:0]};
                    2'b01: DataRd = {24'h000000, read_word[15:8]};
                    2'b10: DataRd = {24'h000000, read_word[23:16]};
                    2'b11: DataRd = {24'h000000, read_word[31:24]};
                    default: DataRd = 32'h0;
                endcase

            default: DataRd = 32'h0;
        endcase
    end
    
endmodule
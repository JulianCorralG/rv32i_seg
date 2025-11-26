module RegistersUnit (
    input logic clk, RUWr,
    input logic [4:0] Rs1, Rs2, Rd,
    input logic [31:0] DataWr,

    output logic [31:0] RURs1,
    output logic [31:0] RURs2
);
    logic [31:0] RU [31:0];

    // initial begin
    //     RU[2] = 32'b1000000000; //512
    // end

    // Corrección de la lectura: Si el índice es 0, la salida es 0.
    assign RURs1 = (Rs1 == 5'b0) ? 32'h00000000 : RU[Rs1];
    assign RURs2 = (Rs2 == 5'b0) ? 32'h00000000 : RU[Rs2];

    always @(posedge clk) begin
        if(RUWr && (Rd != 0))
            RU[Rd] <= DataWr;
    end
endmodule
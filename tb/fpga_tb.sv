module fpga_tb;
    logic clk;
    logic rst_n;
    logic [15:0] LEDS;

    fpga_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .LEDS(LEDS)
    );

    // Generación de reloj
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/fpga_tb.vcd");
        $dumpvars(0, fpga_tb);

        clk = 0;
        rst_n = 0; // Reset activo (bajo)
        #20;
        rst_n = 1; // Soltar reset

        // Esperar ejecución
        #200;

        $finish;
    end
endmodule

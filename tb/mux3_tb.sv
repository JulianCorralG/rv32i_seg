module mux3_tb;
    logic [1:0] sel;
    logic [31:0] a, b, c, y;

    Mux3 #(32) dut (
        .sel(sel),
        .a(a),
        .b(b),
        .c(c),
        .y(y)
    );

    initial begin
        $dumpfile("sim/mux3_tb.vcd");
        $dumpvars(0, mux3_tb);

        a = 10; b = 20; c = 30;

        sel = 0; #10;
        if (y !== a) $error("Error: Sel=0, expected A");

        sel = 1; #10;
        if (y !== b) $error("Error: Sel=1, expected B");

        sel = 2; #10;
        if (y !== c) $error("Error: Sel=2, expected C");

        sel = 3; #10;
        if (y !== a) $display("Info: Sel=3 (default), returns A (or default behavior)");

        $display("Mux3 Testbench Completed");
        $finish;
    end
endmodule

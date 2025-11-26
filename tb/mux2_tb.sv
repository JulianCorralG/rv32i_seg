module mux2_tb;
    logic sel;
    logic [31:0] a, b, y;

    Mux2 #(32) dut (
        .sel(sel),
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("sim/mux2_tb.vcd");
        $dumpvars(0, mux2_tb);

        a = 32'hAAAA_AAAA;
        b = 32'h5555_5555;

        sel = 0; #10;
        if (y !== a) $error("Error: Sel=0, expected A");

        sel = 1; #10;
        if (y !== b) $error("Error: Sel=1, expected B");

        $display("Mux2 Testbench Completed");
        $finish;
    end
endmodule

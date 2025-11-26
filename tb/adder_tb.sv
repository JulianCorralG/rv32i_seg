module adder_tb;
    logic [31:0] a;
    logic [31:0] y;

    Adder dut (
        .PCOutput(a),
        .AdderOutput(y)
    );

    initial begin
        $dumpfile("sim/adder_tb.vcd");
        $dumpvars(0, adder_tb);

        a = 0; #10;
        if (y !== 4) $error("Error: 0 + 4 != %d", y);

        a = 100; #10;
        if (y !== 104) $error("Error: 100 + 4 != %d", y);

        a = 32'hFFFFFFFC; #10; // -4 en complemento a 2
        if (y !== 0) $error("Error: -4 + 4 != %d", y);

        $display("Adder Testbench Completed");
        $finish;
    end
endmodule

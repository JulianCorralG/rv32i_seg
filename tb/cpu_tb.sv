module cpu_tb;
    logic clk, reset;
    logic [31:0] WriteData, DataAdr;

    cpu_top dut (
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAdr(DataAdr)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/cpu_tb.vcd");
        $dumpvars(0, cpu_tb);

        clk = 0; reset = 1;
        #10;
        reset = 0;

        // Esperar suficientes ciclos para que el programa termine
        // El programa tiene 4 instrucciones. 
        // 1. ADDI x0, x0, 0
        // 2. ADDI x1, x0, 5
        // 3. ADDI x2, x0, 10
        // 4. ADD x3, x1, x2
        
        // Ciclo 1: Fetch Instr 1
        // Ciclo 2: Fetch Instr 2
        // Ciclo 3: Fetch Instr 3
        // Ciclo 4: Fetch Instr 4 (Write x3 happens at end of this cycle/start of next)
        
        wait(dut.reg_unit.RU[3] === 32'd15); // Esperar hasta que x3 sea 15
        
        #20; // Un par de ciclos extra
        
        if (dut.reg_unit.RU[3] === 32'd15) begin
            $display("SUCCESS: x3 = 15 as expected.");
        end else begin
            $error("FAILURE: x3 = %d, expected 15.", dut.reg_unit.RU[3]);
        end

        $finish;
    end
endmodule

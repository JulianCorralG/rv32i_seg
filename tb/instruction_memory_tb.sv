module instruction_memory_tb;
    logic [31:0] Address;
    logic [31:0] Instruction;

    InstructionMemory dut (
        .Address_PC(Address),
        .Instruction(Instruction)
    );

    initial begin
        $dumpfile("sim/instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);

        // Asume que program.hex tiene datos. Si no, leerá X o Z.
        // Probamos lectura básica.
        Address = 0; #10;
        $display("Instr at 0: %h", Instruction);

        Address = 4; #10;
        $display("Instr at 4: %h", Instruction);

        $display("InstructionMemory Testbench Completed");
        $finish;
    end
endmodule

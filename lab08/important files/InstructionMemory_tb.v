`timescale 1ns/1ps

module Instruction_Memory_tb;

reg [4:0] addr;
wire [31:0] instruction;

Instruction_Memory uut (
    .addr(addr),
    .instruction(instruction)
);

integer i;

initial begin
    $display("Time\tAddress\tInstruction");

    for(i = 0; i < 32; i = i + 1) begin
        addr = i;
        #10;
        $display("%0t\t%d\t%b", $time, addr, instruction);
    end

    #10 $stop;
end

endmodule


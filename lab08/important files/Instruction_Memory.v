module Instruction_Memory (
    input [4:0] addr,
    output [33:0] instruction
);
    reg [33:0] rom [0:31];

    initial begin
        $readmemb("mem_file.txt", rom); 
    end

    assign instruction = rom[addr];
endmodule

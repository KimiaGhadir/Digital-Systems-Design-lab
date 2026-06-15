`timescale 1ns/1ps

module Pipelined_Computer_tb;

    reg clk;
    reg reset;

    wire [4:0] pc_out;
    wire signed [15:0] Yr_out;
    wire signed [15:0] Yi_out;
    wire done_out;

    Pipelined_Computer uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .Yr_out(Yr_out),
        .Yi_out(Yi_out),
        .done_out(done_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #20
        reset = 0;

        #3000
        $stop;
    end

    initial begin
        $display("---------------------------------------------------------------------------------------------------");
        $display("TIME | PC | OPC |     Ar     Ai |     Br     Bi |      Yr      Yi | DONE");
        $display("---------------------------------------------------------------------------------------------------");
    end

    always @(posedge clk) begin

        $display("%5t | %2d |  %b  | %6d %6d | %6d %6d | %8d %8d |  %b",
            $time,
            pc_out,
            uut.opcode,
            uut.Ar, uut.Ai,
            uut.Br, uut.Bi,
            Yr_out, Yi_out,
            done_out
        );

    end

endmodule


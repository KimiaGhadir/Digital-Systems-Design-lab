`timescale 1ns/1ps

module Complex_ALU_tb;

    reg clk;
    reg reset;
    reg signed [7:0] Ar, Ai, Br, Bi;
    reg [1:0] opcode;
    reg start;
    wire signed [15:0] Yr, Yi;
    wire done;

    Complex_ALU uut (
        .clk(clk),
        .reset(reset),
        .Ar(Ar),
        .Ai(Ai),
        .Br(Br),
        .Bi(Bi),
        .opcode(opcode),
        .start(start),
        .Yr(Yr),
        .Yi(Yi),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_op;
        input signed [7:0] tAr, tAi, tBr, tBi;
        input [1:0] topcode;
        begin
            @(negedge clk);
            Ar = tAr;
            Ai = tAi;
            Br = tBr;
            Bi = tBi;
            opcode = topcode;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            wait(done == 1'b1);
            @(negedge clk);

            $display("TIME=%0t opcode=%b A=(%0d,%0d) B=(%0d,%0d) => Y=(%0d,%0d)",
                     $time, opcode, Ar, Ai, Br, Bi, Yr, Yi);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        Ar = 0; Ai = 0; Br = 0; Bi = 0;
        opcode = 0;
        start = 0;

        #20;
        reset = 0;

        // opcode = 00 : add
        // (3 + j2) + (1 + j4) = (4 + j6)
        run_op(8'sd3, 8'sd2, 8'sd1, 8'sd4, 2'b00);

        // opcode = 01 : sub
        // (7 + j5) - (2 + j3) = (5 + j2)
        run_op(8'sd7, 8'sd5, 8'sd2, 8'sd3, 2'b01);

        // opcode = 10 : multiply
        // (2 + j3)(4 + j5) = (8-15) + j(10+12) = -7 + j22
        run_op(8'sd2, 8'sd3, 8'sd4, 8'sd5, 2'b10);

        // another multiply
        // (1 + j1)(1 + j1) = 0 + j2
        run_op(8'sd1, 8'sd1, 8'sd1, 8'sd1, 2'b10);

        #50;
        $stop;
    end

endmodule


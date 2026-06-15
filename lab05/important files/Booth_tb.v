`timescale 1ns / 1ps

module BoothMul_tb;

    parameter N = 4;
    reg clk;
    reg reset;
    reg start;
    reg signed [N-1:0] M_in;
    reg signed [N-1:0] Q_in;
    wire signed [2*N-1:0] P;
    wire done;

    integer i, j;
    integer passed_count = 0;
    integer failed_count = 0;
    integer expected_val;

    BoothMul #(.N(N)) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .M_in(M_in),
        .Q_in(Q_in),
        .P(P),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        start = 0;
        M_in = 0;
        Q_in = 0;

        #20 reset = 0;
        #10;

        $display("----- Start exhaustive test for 4-bit signed inputs (-8..7) -----");

        for (i = -8; i < 8; i = i + 1) begin
            for (j = -8; j < 8; j = j + 1) begin

                M_in = i;
                Q_in = j;
                start = 1;
                #10 start = 0;

                wait (done);

                expected_val = i * j;

                if ($signed(P) == expected_val) begin
                    passed_count = passed_count + 1;
                    $display("TEST: %4d * %4d = %4d, expected = %4d  --> PASS",
                             i, j, $signed(P), expected_val);
                end
                else begin
                    failed_count = failed_count + 1;
                    $display("TEST: %4d * %4d = %4d, expected = %4d  --> FAIL",
                             i, j, $signed(P), expected_val);
                end

                #10;
            end
        end

        $display("-------------------------------------------------");
        $display("Total tests : %0d", 16*16);
        $display("Passed      : %0d", passed_count);
        $display("Failed      : %0d", failed_count);
        $display("-------------------------------------------------");
        $finish;
    end

endmodule

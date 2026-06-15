`timescale 1ns / 1ps

module Multiplier_tb();

    reg signed [7:0] A;
    reg signed [7:0] B;
    wire signed [15:0] Out;

    Multiplier uut (
        .A(A), 
        .B(B), 
        .Out(Out)
    );

    initial begin
        A = 0; B = 0;
        #5;

        $display("Time\t A \t B \t Out (Hex) \t Out (Decimal)");
        $display("---------------------------------------------------------");

        A = 8'd10; B = 8'd5;
        #10;
        $display("%0t\t %d \t %d \t %h \t\t %d", $time, A, B, Out, Out);

        A = 8'd12; B = -8'sd3;
        #10;
        $display("%0t\t %d \t %d \t %h \t\t %d", $time, A, B, Out, Out);

        A = -8'sd4; B = -8'sd6;
        #10;
        $display("%0t\t %d \t %d \t %h \t\t %d", $time, A, B, Out, Out);

        A = 8'd127; B = 8'd0;
        #10;
        $display("%0t\t %d \t %d \t %h \t\t %d", $time, A, B, Out, Out);

        A = 8'd127; B = 8'd2;
        #10;
        $display("%0t\t %d \t %d \t %h \t\t %d", $time, A, B, Out, Out);

        #10;
        $finish;
    end

endmodule

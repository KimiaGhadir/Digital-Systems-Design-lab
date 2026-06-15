`timescale 1ns / 1ps

module Adder_Subtractor_tb();

    reg signed [15:0] A;
    reg signed [15:0] B;
    reg ctrl;
    wire signed [15:0] Out;

    Adder_Subtractor uut (
        .A(A), 
        .B(B), 
        .ctrl(ctrl), 
        .Out(Out)
    );

    initial begin
        A = 0; B = 0; ctrl = 0;
        #5; 

	$display("Time\tA\tB\tctrl\tOut");

        A = 16'd10; B = 16'd5; ctrl = 1'b0;
	#10;
    	$display("%0t\t%d\t%d\t%b\t%d",$time,A,B,ctrl,Out);
        
        A = 16'd20; B = 16'd8; ctrl = 1'b1;
        #10;
	$display("%0t\t%d\t%d\t%b\t%d",$time,A,B,ctrl,Out);


        A = 16'd15; B = -16'd20;
        ctrl = 1'b0;
        #10;
	$display("%0t\t%d\t%d\t%b\t%d",$time,A,B,ctrl,Out);

        A = -16'd50; B = -16'd10; ctrl = 1'b1;
        #10;
	$display("%0t\t%d\t%d\t%b\t%d",$time,A,B,ctrl,Out);

        $display("Simulation Finished. Check the Waveform window.");
        $finish;
    end

endmodule

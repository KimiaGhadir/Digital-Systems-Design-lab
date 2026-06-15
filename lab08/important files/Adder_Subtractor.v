module Adder_Subtractor (
    input signed [15:0] A, 
    input signed [15:0] B,
    input ctrl,
    output signed [15:0] Out
);
    assign Out = ctrl ? (A - B) : (A + B);
endmodule

module Multiplier (
    input signed [7:0] A, 
    input signed [7:0] B,
    output signed [15:0] Out
);
    assign Out = A * B;
endmodule

module serial_comparator (
    input  wire a,
    input  wire b,
    input  wire clk,
    input  wire rst,
    output wire greater,
    output wire equal,
    output wire less
);

    wire g_b;
    wire e_b;
    wire l_b;

    assign g_b = greater | (equal & a & ~b);
    assign e_b = equal & ~(a ^ b);
    assign l_b = less | (equal & ~a & b);

    assign greater = (rst) ? 1'b0 : ((clk) ? g_b : greater);
    assign equal   = (rst) ? 1'b1 : ((clk) ? e_b : equal);
    assign less    = (rst) ? 1'b0 : ((clk) ? l_b : less);

endmodule

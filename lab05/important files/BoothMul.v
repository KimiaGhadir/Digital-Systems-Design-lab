module BoothMul #(parameter N = 4) (
    input wire clk,
    input wire reset,
    input wire start,
    input wire signed [N-1:0] M_in,
    input wire signed [N-1:0] Q_in,
    output wire signed [2*N-1:0] P,
    output wire done
);

    wire q0, qm1;
    wire load, do_add, do_sub, do_shift;

    DataPath #(.N(N)) dp (
        .clk(clk),
        .reset(reset),
        .load(load),
        .do_add(do_add),
        .do_sub(do_sub),
        .do_shift(do_shift),
        .M_in(M_in),
        .Q_in(Q_in),
        .q0(q0),
        .qm1(qm1),
        .P(P)
    );

    ControlUnit #(.N(N)) cu (
        .clk(clk),
        .reset(reset),
        .start(start),
        .q0(q0),
        .qm1(qm1),
        .load(load),
        .do_add(do_add),
        .do_sub(do_sub),
        .do_shift(do_shift),
        .done(done)
    );

endmodule

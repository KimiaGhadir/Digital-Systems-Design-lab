module DataPath #(
  parameter N = 4
)(
  input  wire                  clk,
  input  wire                  reset,
  input  wire                  load,
  input  wire                  do_add,
  input  wire                  do_sub,
  input  wire                  do_shift,
  input  wire signed [N-1:0]   M_in,
  input  wire signed [N-1:0]   Q_in,
  output wire                  q0,
  output wire                  qm1,
  output reg  signed [2*N-1:0] P
);

  reg signed [N:0]   A;
  reg signed [N-1:0] Q;
  reg                Qm1;
  reg signed [N-1:0] M;

  assign q0  = Q[0];
  assign qm1 = Qm1;


  always @(*) begin
    P = {A[N-1:0], Q};
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      A   <= 'd0;
      Q   <= 'd0;
      Qm1 <= 1'b0;
      M   <= 'd0;
    end else begin
      if (load) begin
        A   <= 'd0;
        Q   <= Q_in;
        Qm1 <= 1'b0;
        M   <= M_in;
      end else if (do_add) begin
        A <= A + M;
      end else if (do_sub) begin
        A <= A - M;
      end else if (do_shift) begin
        {A, Q, Qm1} <= {A[N], A, Q};
      end
    end
  end

endmodule


`timescale 1ns/1ps

module DataPath_tb;

  localparam N = 4;

  reg clk;
  reg reset;
  reg load;
  reg do_add;
  reg do_sub;
  reg do_shift;
  reg signed [N-1:0] M_in;
  reg signed [N-1:0] Q_in;

  wire q0;
  wire qm1;
  wire signed [2*N-1:0] P;

  DataPath #(.N(N)) dut (
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

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task clear_ctrl;
    begin
      load     = 0;
      do_add   = 0;
      do_sub   = 0;
      do_shift = 0;
    end
  endtask

  task pulse_load(input signed [N-1:0] m, input signed [N-1:0] q);
    begin
      @(negedge clk);
      M_in = m;
      Q_in = q;
      load = 1;
      do_add = 0; do_sub = 0; do_shift = 0;
      @(negedge clk);
      load = 0;
    end
  endtask

  task pulse_add;
    begin
      @(negedge clk);
      clear_ctrl();
      do_add = 1;
      @(negedge clk);
      do_add = 0;
    end
  endtask

  task pulse_sub;
    begin
      @(negedge clk);
      clear_ctrl();
      do_sub = 1;
      @(negedge clk);
      do_sub = 0;
    end
  endtask

  task pulse_shift;
    begin
      @(negedge clk);
      clear_ctrl();
      do_shift = 1;
      @(negedge clk);
      do_shift = 0;
    end
  endtask

  initial begin
    reset = 1;
    clear_ctrl();
    M_in = 0;
    Q_in = 0;

    #12 reset = 0;

    pulse_load(4'sd3, 4'sd2);
    pulse_shift();
    pulse_add();
    pulse_shift();
    pulse_sub();
    pulse_shift();

    pulse_load(-4'sd3, 4'sd2);
    pulse_add();
    pulse_shift();
    pulse_sub();
    pulse_shift();

    pulse_load(4'sd7, -4'sd1);
    pulse_shift();
    pulse_shift();
    pulse_add();
    pulse_shift();

    #50 $stop;
  end

endmodule

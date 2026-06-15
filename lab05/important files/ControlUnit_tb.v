`timescale 1ns / 1ps

module ControlUnit_tb;

    parameter N = 4;

    reg clk;
    reg reset;
    reg start;
    reg q0;
    reg qm1;

    wire load;
    wire do_add;
    wire do_sub;
    wire do_shift;
    wire done;

    ControlUnit #(.N(N)) uut (
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

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        q0 = 0;
        qm1 = 0;

        #20 reset = 0;

        #10 start = 1;
        #10 start = 0;

        #20 q0 = 1; qm1 = 0;
        
        #20 q0 = 0; qm1 = 1;

        wait(done);
        $display("Test Finished: Operation Done.");
        #20 $finish;
    end

    initial begin
        $monitor("Time=%0t | State=%b | Load=%b | Add=%b | Sub=%b | Shift=%b | Done=%b", 
                  $time, uut.state, load, do_add, do_sub, do_shift, done);
    end

endmodule

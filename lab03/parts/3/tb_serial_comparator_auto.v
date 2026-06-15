`timescale 1ns/1ps

module tb_serial_comparator_auto;

    reg a, b, clk, rst;
    wire greater, equal, less;

    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    reg exp_greater, exp_equal, exp_less;
    reg [3:0] A, B;
    integer k;

    serial_comparator dut (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .greater(greater),
        .equal(equal),
        .less(less)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task apply_vector;
        input [3:0] inA;
        input [3:0] inB;
        begin
            A = inA;
            B = inB;

            rst = 1;
            a = 0;
            b = 0;
            #12;
            rst = 0;

            for (k = 3; k >= 0; k = k - 1) begin
                @(negedge clk);
                a = A[k];
                b = B[k];
                @(posedge clk);
                #1;
            end

            exp_greater = (A > B);
            exp_equal   = (A == B);
            exp_less    = (A < B);

            total_tests = total_tests + 1;

            if ((greater === exp_greater) &&
                (equal   === exp_equal)   &&
                (less    === exp_less)) begin
                passed_tests = passed_tests + 1;
                $display("PASS | A=%4b B=%4b || out=%b%b%b",
                         A, B, greater, equal, less);
            end
            else begin
                failed_tests = failed_tests + 1;
                $display("FAIL | A=%4b B=%4b || out=%b%b%b expected=%b%b%b",
                         A, B,
                         greater, equal, less,
                         exp_greater, exp_equal, exp_less);
            end
        end
    endtask

    initial begin
        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        apply_vector(4'b0000, 4'b0000);
        apply_vector(4'b0001, 4'b0000);
        apply_vector(4'b0000, 4'b0001);
        apply_vector(4'b1011, 4'b1001);
        apply_vector(4'b0110, 4'b0110);
        apply_vector(4'b1111, 4'b0111);
        apply_vector(4'b0011, 4'b1010);
        apply_vector(4'b1000, 4'b1001);

        $display("======================================");
        $display("Total Tests  = %0d", total_tests);
        $display("Passed Tests = %0d", passed_tests);
        $display("Failed Tests = %0d", failed_tests);
        $display("======================================");

        $stop;
    end

endmodule

`timescale 1ns/1ps

module tb_comparator_auto;

    reg [3:0] a, b;
    wire greater, equal, less;

    integer i, j;
    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    reg exp_greater, exp_equal, exp_less;

    comparator dut (
        .a(a),
        .b(b),
        .greater(greater),
        .equal(equal),
        .less(less)
    );

    initial begin
        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];

                #1;

                exp_greater = (i > j);
                exp_equal   = (i == j);
                exp_less    = (i < j);

                total_tests = total_tests + 1;

                if ((greater === exp_greater) &&
                    (equal   === exp_equal)   &&
                    (less    === exp_less)) begin
                    passed_tests = passed_tests + 1;
                    $display("PASS | a=%4b b=%4b || out=%b%b%b",
                             a, b, greater, equal, less);
                end
                else begin
                    failed_tests = failed_tests + 1;
                    $display("FAIL | a=%4b b=%4b || out=%b%b%b expected=%b%b%b",
                             a, b,
                             greater, equal, less,
                             exp_greater, exp_equal, exp_less);
                end
            end
        end

        $display("======================================");
        $display("Total Tests  = %0d", total_tests);
        $display("Passed Tests = %0d", passed_tests);
        $display("Failed Tests = %0d", failed_tests);
        $display("======================================");

        $stop;
    end

endmodule

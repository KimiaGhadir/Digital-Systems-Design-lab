`timescale 1ns/1ps

module tb_castcadable_comparator_auto;

    reg in_gr, in_eq, in_le;
    reg a, b;
    wire out_gr, out_eq, out_le;

    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    reg exp_gr, exp_eq, exp_le;

    castcadable_comparator dut (
        .in_gr(in_gr),
        .in_eq(in_eq),
        .in_le(in_le),
        .a(a),
        .b(b),
        .out_gr(out_gr),
        .out_eq(out_eq),
        .out_le(out_le)
    );

    task run_test;
        input tin_gr, tin_eq, tin_le;
        input ta, tb;
        begin
            in_gr = tin_gr;
            in_eq = tin_eq;
            in_le = tin_le;
            a = ta;
            b = tb;

            #1;

            exp_gr = tin_gr | (tin_eq & (ta & (~tb)));
            exp_eq = tin_eq & ~(ta ^ tb);
            exp_le = tin_le | (tin_eq & ((~ta) & tb));

            total_tests = total_tests + 1;

            if ((out_gr === exp_gr) && (out_eq === exp_eq) && (out_le === exp_le)) begin
                passed_tests = passed_tests + 1;
                $display("PASS | in_gr=%b in_eq=%b in_le=%b a=%b b=%b || out=%b%b%b",
                         tin_gr, tin_eq, tin_le, ta, tb, out_gr, out_eq, out_le);
            end
            else begin
                failed_tests = failed_tests + 1;
                $display("FAIL | in_gr=%b in_eq=%b in_le=%b a=%b b=%b || out=%b%b%b expected=%b%b%b",
                         tin_gr, tin_eq, tin_le, ta, tb,
                         out_gr, out_eq, out_le,
                         exp_gr, exp_eq, exp_le);
            end
        end
    endtask

    initial begin
        total_tests = 0;
        passed_tests = 0;
        failed_tests = 0;

        run_test(0,1,0,0,0);
        run_test(0,1,0,0,1);
        run_test(0,1,0,1,0);
        run_test(0,1,0,1,1);

        run_test(1,0,0,0,0);
        run_test(1,0,0,0,1);
        run_test(1,0,0,1,0);
        run_test(1,0,0,1,1);

        run_test(0,0,1,0,0);
        run_test(0,0,1,0,1);
        run_test(0,0,1,1,0);
        run_test(0,0,1,1,1);

        run_test(0,0,0,0,0);
        run_test(0,0,0,0,1);
        run_test(0,0,0,1,0);
        run_test(0,0,0,1,1);

        run_test(1,1,1,0,0);

        $display("======================================");
        $display("Total Tests  = %0d", total_tests);
        $display("Passed Tests = %0d", passed_tests);
        $display("Failed Tests = %0d", failed_tests);
        $display("======================================");

        $stop;
    end

endmodule

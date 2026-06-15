`timescale 1ns/1ps

module tb_digital_control;

    localparam TEMP_WIDTH = 8;
    localparam CLK_PERIOD = 10;

    // Heater/Cooler states, matched with DUT encoding
    localparam [1:0] TH_IDLE = 2'd0;
    localparam [1:0] TH_COOL = 2'd1;
    localparam [1:0] TH_HEAT = 2'd2;
    localparam [1:0] TH_BAD  = 2'd3;

    // Cooler speed states, matched with DUT encoding
    localparam [1:0] CRS_OUT = 2'd0;
    localparam [1:0] CRS_4   = 2'd1;
    localparam [1:0] CRS_6   = 2'd2;
    localparam [1:0] CRS_8   = 2'd3;

    reg clk;
    reg rst_n;
    reg signed [TEMP_WIDTH-1:0] temp_c;

    wire heater_on;
    wire cooler_on;
    wire [3:0] cooler_speed_rps;
    wire [1:0] thermal_state_dbg;
    wire [1:0] speed_state_dbg;

    integer errors;
    integer tests;
    integer ts;
    integer ss;
    integer t;

    digital_control_top #(
        .TEMP_WIDTH(TEMP_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .temp_c(temp_c),
        .heater_on(heater_on),
        .cooler_on(cooler_on),
        .cooler_speed_rps(cooler_speed_rps),
        .thermal_state_dbg(thermal_state_dbg),
        .speed_state_dbg(speed_state_dbg)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    function [1:0] exp_thermal_next;
        input [1:0] state;
        input signed [TEMP_WIDTH-1:0] temp;
        begin
            exp_thermal_next = state;
            case (state)
                TH_IDLE: begin
                    if (temp > 8'sd35) begin
                        exp_thermal_next = TH_COOL;
                    end else if (temp < 8'sd15) begin
                        exp_thermal_next = TH_HEAT;
                    end
                end

                TH_COOL: begin
                    if (temp < 8'sd25) begin
                        exp_thermal_next = TH_IDLE;
                    end
                end

                TH_HEAT: begin
                    if (temp > 8'sd30) begin
                        exp_thermal_next = TH_IDLE;
                    end
                end

                default: begin
                    exp_thermal_next = TH_IDLE;
                end
            endcase
        end
    endfunction

    function [1:0] exp_speed_next;
        input [1:0] th_state;
        input [1:0] sp_state;
        input signed [TEMP_WIDTH-1:0] temp;
        reg [1:0] th_next;
        begin
            th_next = exp_thermal_next(th_state, temp);

            if (th_next != TH_COOL) begin
                exp_speed_next = CRS_OUT;
            end else begin
                exp_speed_next = sp_state;
                case (sp_state)
                    CRS_OUT: begin
                        if (temp > 8'sd35) begin
                            exp_speed_next = CRS_4;
                        end
                    end

                    CRS_4: begin
                        if (temp < 8'sd25) begin
                            exp_speed_next = CRS_OUT;
                        end else if (temp > 8'sd40) begin
                            exp_speed_next = CRS_6;
                        end
                    end

                    CRS_6: begin
                        if (temp < 8'sd35) begin
                            exp_speed_next = CRS_4;
                        end else if (temp > 8'sd45) begin
                            exp_speed_next = CRS_8;
                        end
                    end

                    CRS_8: begin
                        if (temp < 8'sd40) begin
                            exp_speed_next = CRS_6;
                        end
                    end

                    default: begin
                        exp_speed_next = CRS_OUT;
                    end
                endcase
            end
        end
    endfunction

    function exp_heater;
        input [1:0] th_state;
        begin
            exp_heater = (th_state == TH_HEAT);
        end
    endfunction

    function exp_cooler;
        input [1:0] th_state;
        begin
            exp_cooler = (th_state == TH_COOL);
        end
    endfunction

    function [3:0] exp_speed_rps;
        input [1:0] th_state;
        input [1:0] sp_state;
        begin
            if (th_state != TH_COOL) begin
                exp_speed_rps = 4'd0;
            end else begin
                case (sp_state)
                    CRS_OUT: exp_speed_rps = 4'd0;
                    CRS_4:   exp_speed_rps = 4'd4;
                    CRS_6:   exp_speed_rps = 4'd6;
                    CRS_8:   exp_speed_rps = 4'd8;
                    default: exp_speed_rps = 4'd0;
                endcase
            end
        end
    endfunction

    task apply_reset;
        begin
            @(negedge clk);
            rst_n  = 1'b0;
            temp_c = 8'sd20;
            repeat (2) @(posedge clk);
            #1;
            check_state_and_outputs(TH_IDLE, CRS_OUT, "reset must put both FSMs in safe idle state");
            @(negedge clk);
            rst_n = 1'b1;
        end
    endtask

    task step_temp_and_check;
        input signed [TEMP_WIDTH-1:0] new_temp;
        input [1:0] exp_th;
        input [1:0] exp_sp;
        input [8*80-1:0] msg;
        begin
            @(negedge clk);
            temp_c = new_temp;
            @(posedge clk);
            #1;
            check_state_and_outputs(exp_th, exp_sp, msg);
        end
    endtask

    task check_state_and_outputs;
        input [1:0] exp_th;
        input [1:0] exp_sp;
        input [8*80-1:0] msg;
        begin
            tests = tests + 1;
            if (thermal_state_dbg !== exp_th ||
                speed_state_dbg   !== exp_sp ||
                heater_on         !== exp_heater(exp_th) ||
                cooler_on         !== exp_cooler(exp_th) ||
                cooler_speed_rps  !== exp_speed_rps(exp_th, exp_sp)) begin

                errors = errors + 1;
                $display("ERROR at time %0t | %0s", $time, msg);
                $display("  temp=%0d", temp_c);
                $display("  expected: thermal=%0d speed=%0d heater=%0b cooler=%0b rps=%0d",
                         exp_th, exp_sp, exp_heater(exp_th), exp_cooler(exp_th), exp_speed_rps(exp_th, exp_sp));
                $display("  observed: thermal=%0d speed=%0d heater=%0b cooler=%0b rps=%0d",
                         thermal_state_dbg, speed_state_dbg, heater_on, cooler_on, cooler_speed_rps);
            end
        end
    endtask

    task forced_transition_check;
        input [1:0] init_th;
        input [1:0] init_sp;
        input signed [TEMP_WIDTH-1:0] new_temp;
        reg [1:0] e_th;
        reg [1:0] e_sp;
        begin
            @(negedge clk);
            rst_n  = 1'b1;
            temp_c = new_temp;
            force dut.thermal_state = init_th;
            force dut.speed_state   = init_sp;
            #1;

            e_th = exp_thermal_next(init_th, new_temp);
            e_sp = exp_speed_next(init_th, init_sp, new_temp);

            release dut.thermal_state;
            release dut.speed_state;
            @(posedge clk);
            #1;

            tests = tests + 1;
            if (thermal_state_dbg !== e_th || speed_state_dbg !== e_sp ||
                heater_on !== exp_heater(e_th) || cooler_on !== exp_cooler(e_th) ||
                cooler_speed_rps !== exp_speed_rps(e_th, e_sp)) begin
                errors = errors + 1;
                $display("ERROR at time %0t | exhaustive transition mismatch", $time);
                $display("  init thermal=%0d init speed=%0d temp=%0d", init_th, init_sp, new_temp);
                $display("  expected next thermal=%0d next speed=%0d heater=%0b cooler=%0b rps=%0d",
                         e_th, e_sp, exp_heater(e_th), exp_cooler(e_th), exp_speed_rps(e_th, e_sp));
                $display("  observed next thermal=%0d next speed=%0d heater=%0b cooler=%0b rps=%0d",
                         thermal_state_dbg, speed_state_dbg, heater_on, cooler_on, cooler_speed_rps);
            end
        end
    endtask

    task run_reset_test;
        begin
            $display("TEST 1: reset behavior");
            apply_reset();
        end
    endtask

    task run_directed_thermal_sequence;
        begin
            $display("TEST 2: directed heater/cooler ON-OFF sequence");
            apply_reset();
            step_temp_and_check(8'sd36, TH_COOL, CRS_4,   "36C: idle -> cooler ON and CRS=4");
            step_temp_and_check(8'sd34, TH_COOL, CRS_4,   "34C: cooler state is held by hysteresis");
            step_temp_and_check(8'sd24, TH_IDLE, CRS_OUT, "24C: cooler turns OFF, CRS -> OUT");
            step_temp_and_check(8'sd14, TH_HEAT, CRS_OUT, "14C: heater turns ON");
            step_temp_and_check(8'sd20, TH_HEAT, CRS_OUT, "20C: heater state is held by hysteresis");
            step_temp_and_check(8'sd31, TH_IDLE, CRS_OUT, "31C: heater turns OFF");
        end
    endtask

    task run_directed_speed_sequence;
        begin
            $display("TEST 3: directed cooler speed increase/decrease sequence");
            apply_reset();
            step_temp_and_check(8'sd36, TH_COOL, CRS_4,   "36C: OUT -> 4 RPS");
            step_temp_and_check(8'sd41, TH_COOL, CRS_6,   "41C: 4 RPS -> 6 RPS");
            step_temp_and_check(8'sd44, TH_COOL, CRS_6,   "44C: 6 RPS is held below 46C");
            step_temp_and_check(8'sd46, TH_COOL, CRS_8,   "46C: 6 RPS -> 8 RPS");
            step_temp_and_check(8'sd44, TH_COOL, CRS_8,   "44C: 8 RPS is held until T < 40C");
            step_temp_and_check(8'sd39, TH_COOL, CRS_6,   "39C: 8 RPS -> 6 RPS");
            step_temp_and_check(8'sd34, TH_COOL, CRS_4,   "34C: 6 RPS -> 4 RPS");
            step_temp_and_check(8'sd24, TH_IDLE, CRS_OUT, "24C: 4 RPS -> OUT");
        end
    endtask

    task run_boundary_tests;
        begin
            $display("TEST 4: exact boundary values; all thresholds are strict");

            // Thermal boundaries
            forced_transition_check(TH_IDLE, CRS_OUT, 8'sd15); // not below 15
            forced_transition_check(TH_IDLE, CRS_OUT, 8'sd35); // not above 35
            forced_transition_check(TH_IDLE, CRS_OUT, 8'sd14); // below 15
            forced_transition_check(TH_IDLE, CRS_OUT, 8'sd36); // above 35

            forced_transition_check(TH_COOL, CRS_4, 8'sd25);   // not below 25
            forced_transition_check(TH_COOL, CRS_4, 8'sd24);   // below 25
            forced_transition_check(TH_HEAT, CRS_OUT, 8'sd30); // not above 30
            forced_transition_check(TH_HEAT, CRS_OUT, 8'sd31); // above 30

            // Speed boundaries while cooling is active
            forced_transition_check(TH_COOL, CRS_OUT, 8'sd35); // OUT holds at 35
            forced_transition_check(TH_COOL, CRS_OUT, 8'sd36); // OUT -> 4 at 36
            forced_transition_check(TH_COOL, CRS_4,   8'sd25); // 4 holds at 25
            forced_transition_check(TH_COOL, CRS_4,   8'sd40); // 4 holds at 40
            forced_transition_check(TH_COOL, CRS_4,   8'sd41); // 4 -> 6 at 41
            forced_transition_check(TH_COOL, CRS_6,   8'sd35); // 6 holds at 35
            forced_transition_check(TH_COOL, CRS_6,   8'sd45); // 6 holds at 45
            forced_transition_check(TH_COOL, CRS_6,   8'sd46); // 6 -> 8 at 46
            forced_transition_check(TH_COOL, CRS_8,   8'sd40); // 8 holds at 40
            forced_transition_check(TH_COOL, CRS_8,   8'sd39); // 8 -> 6 at 39

            // When cooling is not active, speed FSM must go/stay OUT
            forced_transition_check(TH_IDLE, CRS_4,   8'sd36);
            forced_transition_check(TH_HEAT, CRS_6,   8'sd39);
            forced_transition_check(TH_HEAT, CRS_8,   8'sd10);
        end
    endtask

    task run_exhaustive_transition_tests;
        begin
            $display("TEST 5: exhaustive legal transition coverage in valid sensor range (-10C to 60C)");
            for (ts = 0; ts < 3; ts = ts + 1) begin
                for (ss = 0; ss < 4; ss = ss + 1) begin
                    for (t = -10; t <= 60; t = t + 1) begin
                        forced_transition_check(ts[1:0], ss[1:0], t[7:0]);
                    end
                end
            end
            $display("  Checked 3*4*71 = 852 legal-state/temperature transitions.");
        end
    endtask

    task run_illegal_state_recovery_test;
        begin
            $display("TEST 6: safe recovery from illegal thermal state encoding");
            forced_transition_check(TH_BAD, CRS_OUT, 8'sd20);
        end
    endtask

    initial begin
        $dumpfile("digital_control_tb.vcd");
        $dumpvars(0, tb_digital_control);

        errors = 0;
        tests  = 0;
        rst_n  = 1'b1;
        temp_c = 8'sd20;

        run_reset_test();
        run_directed_thermal_sequence();
        run_directed_speed_sequence();
        run_boundary_tests();
        run_exhaustive_transition_tests();
        run_illegal_state_recovery_test();

        if (errors == 0) begin
            $display("------------------------------------------------------------");
            $display("PASS: all %0d checks completed without error.", tests);
            $display("------------------------------------------------------------");
        end else begin
            $display("------------------------------------------------------------");
            $display("FAIL: %0d errors detected in %0d checks.", errors, tests);
            $display("------------------------------------------------------------");
        end

        $finish;
    end

endmodule

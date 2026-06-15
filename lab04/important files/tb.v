module tb();

    reg clk = 0, reset = 0, push = 0, pop = 0;
    reg [3:0] data_in = 0;
    wire full, empty;
    wire [3:0] data_out;

    stack Stack(
        .Clk(clk), .RstN(reset),
        .Push(push), .Pop(pop),
        .Data_In(data_in),
        .Data_Out(data_out),
        .Full(full), .Empty(empty)
    );

    always #10 clk = ~clk;

    task do_push(input [3:0] val);
        begin
        data_in = val; push = 1; pop = 0;
        @(posedge clk); #1;
        end
    endtask
    

    task do_pop;
        begin
        push = 0; pop = 1;
        @(posedge clk); #1;
        end
    endtask

    task idle;
        begin
        push = 0; pop = 0;
        @(posedge clk); #1;
        end
    endtask

    initial begin
        $monitor("t=%0t push=%b pop=%b din=%0d | dout=%0d Full=%b Empty=%b",
                  $time, push, pop, data_in, data_out, full, empty);

        // --- Reset ---
        reset = 0; #25;
        reset = 1; idle;

        // --- Test 1: Push روی Empty ---
        $display("-- Push 8 items --");
        do_push(1); do_push(2); do_push(3); do_push(4);
        do_push(5); do_push(6); do_push(7); do_push(8);

        // --- Test 2: Push روی Full (باید ignore بشه) ---
        $display("-- Push on Full (should be ignored) --");
        do_push(9);
        if (full !== 1) $display("FAIL: Full should be 1");

        // --- Test 3: Pop تا Empty ---
        $display("-- Pop all items --");
        repeat(8) do_pop;

        // --- Test 4: Pop روی Empty (باید ignore بشه) ---
        $display("-- Pop on Empty (should be ignored) --");
        do_pop;
        if (empty !== 1) $display("FAIL: Empty should be 1");

        // --- Test 5: Push و Pop همزمان ---
        $display("-- Simultaneous Push & Pop (should be ignored) --");
        do_push(3); idle; 
        push = 1; pop = 1; data_in = 5;
        @(posedge clk); #1;
        push = 0; pop = 0;

        // --- Test 6: Reset در حین کار ---
        $display("-- Reset mid-operation --");
        do_push(4); do_push(5);
        reset = 0; #25; reset = 1; idle;
        if (empty !== 1) $display("FAIL: should be empty after reset");

        $stop;
    end

endmodule

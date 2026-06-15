`timescale 1ns/1ps

module test_bench;

    parameter Baudrate  = 4;
    parameter Clockrate = 16;

    reg clk;
    reg rst;

    reg start1;
    reg [6:0] data_sender1;

    wire tx1;
    wire rx2;

    wire [6:0] data_receiver2;
    wire parity_receiver2;
    wire [7:0] data_with_parity2;
    wire valid2;
    wire parity_error2;

    wire tx_busy1;
    wire tx_done1;

    assign rx2 = tx1;

    uart #(
        .Baudrate(Baudrate),
        .Clockrate(Clockrate)
    ) uart1 (
        .clk(clk),
        .rst(rst),

        .start(start1),
        .data_sender(data_sender1),

        .rx(1'b1),
        .tx(tx1),

        .data_receiver(),
        .parity_receiver(),
        .data_with_parity(),
        .valid(),
        .parity_error(),

        .tx_busy(tx_busy1),
        .tx_done(tx_done1)
    );

    uart #(
        .Baudrate(Baudrate),
        .Clockrate(Clockrate)
    ) uart2 (
        .clk(clk),
        .rst(rst),

        .start(1'b0),
        .data_sender(7'b0000000),

        .rx(rx2),
        .tx(),

        .data_receiver(data_receiver2),
        .parity_receiver(parity_receiver2),
        .data_with_parity(data_with_parity2),
        .valid(valid2),
        .parity_error(parity_error2),

        .tx_busy(),
        .tx_done()
    );

    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;
    end

    task send_and_check;
        input [6:0] test_data;
        begin
            @(posedge clk);
            data_sender1 <= test_data;
            start1 <= 1'b1;

            @(posedge clk);
            start1 <= 1'b0;

            wait(valid2 == 1'b1);
            @(posedge clk);

            if (parity_error2) begin
                $display("ERROR: Parity error detected for data = %b", test_data);
            end else if (data_receiver2 !== test_data) begin
                $display("ERROR: Sent = %b, Received = %b", test_data, data_receiver2);
            end else begin
                $display("PASS : Sent = %b, Received = %b, Parity = %b, Register8 = %b",
                         test_data, data_receiver2, parity_receiver2, data_with_parity2);
            end

            repeat(5) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("uart_test.vcd");
        $dumpvars(0, test_bench);

        rst = 1'b0;
        start1 = 1'b0;
        data_sender1 = 7'b0000000;

        repeat(5) @(posedge clk);
        rst = 1'b1;

        repeat(5) @(posedge clk);

        send_and_check(7'b0000000);
        send_and_check(7'b1111111);
        send_and_check(7'b1010101);
        send_and_check(7'b1100101);
        send_and_check(7'b0010110);
        send_and_check(7'b1000010);
        send_and_check(7'b0000001);
        send_and_check(7'b1000000);

        repeat(20) @(posedge clk);

        $display("UART test finished.");
        $finish;
    end

endmodule
module uart #(
    parameter Baudrate  = 115200,
    parameter Clockrate = 50000000
)(
    input clk,
    input rst,

    input start,
    input [6:0] data_sender,

    input rx,
    output tx,

    output [6:0] data_receiver,
    output parity_receiver,
    output [7:0] data_with_parity,
    output valid,
    output parity_error,

    output tx_busy,
    output tx_done
);

    sender #(
        .Baudrate(Baudrate),
        .Clockrate(Clockrate)
    ) sender1 (
        .rst(rst),
        .clk(clk),
        .start(start),
        .data(data_sender),
        .serial_out(tx),
        .busy(tx_busy),
        .done(tx_done)
    );

    receiver #(
        .Baudrate(Baudrate),
        .Clockrate(Clockrate)
    ) receiver1 (
        .rst(rst),
        .clk(clk),
        .serial_in(rx),
        .data(data_receiver),
        .parity_bit(parity_receiver),
        .data_with_parity(data_with_parity),
        .valid(valid),
        .parity_error(parity_error)
    );

endmodule
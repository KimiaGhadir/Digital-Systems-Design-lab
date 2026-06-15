module receiver #(
    parameter Baudrate  = 115200,
    parameter Clockrate = 50000000
)(
    input rst,
    input clk,
    input serial_in,
    output reg [6:0] data,
    output reg parity_bit,
    output reg [7:0] data_with_parity,
    output reg valid,
    output reg parity_error
);

    localparam integer CLKS_PER_BIT      = Clockrate / Baudrate;
    localparam integer CLKS_PER_HALF_BIT = CLKS_PER_BIT / 2;

    localparam IDLE   = 3'd0;
    localparam START  = 3'd1;
    localparam PARITY = 3'd2;
    localparam DATA   = 3'd3;
    localparam STOP   = 3'd4;

    reg [2:0] state;
    reg [31:0] delay;
    reg [2:0] bit_counter;
    reg [6:0] data_reg;
    reg parity_reg;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state            <= IDLE;
            delay            <= 0;
            bit_counter      <= 0;
            data             <= 0;
            data_reg         <= 0;
            parity_bit       <= 0;
            parity_reg       <= 0;
            data_with_parity <= 0;
            valid            <= 1'b0;
            parity_error     <= 1'b0;
        end else begin
            valid <= 1'b0;

            case (state)

                IDLE: begin
                    delay        <= 0;
                    bit_counter  <= 0;
                    parity_error <= 1'b0;

                    if (serial_in == 1'b0) begin
                        delay <= CLKS_PER_HALF_BIT - 1;
                        state <= START;
                    end
                end

                START: begin
                    if (delay == 0) begin
                        if (serial_in == 1'b0) begin
                            delay <= CLKS_PER_BIT - 1;
                            state <= PARITY;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        delay <= delay - 1;
                    end
                end

                PARITY: begin
                    if (delay == 0) begin
                        parity_reg <= serial_in;
                        parity_bit <= serial_in;
                        delay      <= CLKS_PER_BIT - 1;
                        state      <= DATA;
                    end else begin
                        delay <= delay - 1;
                    end
                end

                DATA: begin
                    if (delay == 0) begin
                        data_reg[bit_counter] <= serial_in;

                        if (bit_counter == 6) begin
                            delay <= CLKS_PER_BIT - 1;
                            state <= STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                            delay       <= CLKS_PER_BIT - 1;
                        end
                    end else begin
                        delay <= delay - 1;
                    end
                end

                STOP: begin
                    if (delay == 0) begin
                        if (serial_in == 1'b1) begin
                            data <= data_reg;
                            data_with_parity <= {data_reg, parity_reg};

                            if ((^data_reg) == parity_reg) begin
                                parity_error <= 1'b0;
                            end else begin
                                parity_error <= 1'b1;
                            end

                            valid <= 1'b1;
                        end else begin
                            parity_error <= 1'b1;
                        end

                        state <= IDLE;
                    end else begin
                        delay <= delay - 1;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
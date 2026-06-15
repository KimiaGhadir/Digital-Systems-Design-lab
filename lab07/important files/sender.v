module sender #(
    parameter Baudrate  = 115200,
    parameter Clockrate = 50000000
)(
    input rst,
    input clk,
    input start,
    input [6:0] data,
    output reg serial_out,
    output reg busy,
    output reg done
);

    localparam integer CLKS_PER_BIT = Clockrate / Baudrate;

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
            state       <= IDLE;
            delay       <= 0;
            bit_counter <= 0;
            data_reg    <= 0;
            parity_reg  <= 0;
            serial_out  <= 1'b1;
            busy        <= 1'b0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;

            case (state)

                IDLE: begin
                    serial_out  <= 1'b1;
                    busy        <= 1'b0;
                    delay       <= 0;
                    bit_counter <= 0;

                    if (start) begin
                        data_reg    <= data;
                        parity_reg  <= ^data;      // even parity
                        serial_out  <= 1'b0;       // start bit
                        busy        <= 1'b1;
                        delay       <= CLKS_PER_BIT - 1;
                        state       <= START;
                    end
                end

                START: begin
                    if (delay == 0) begin
                        serial_out <= parity_reg;   // parity bit
                        delay      <= CLKS_PER_BIT - 1;
                        state      <= PARITY;
                    end else begin
                        delay <= delay - 1;
                    end
                end

                PARITY: begin
                    if (delay == 0) begin
                        serial_out  <= data_reg[0]; // first data bit
                        bit_counter <= 0;
                        delay       <= CLKS_PER_BIT - 1;
                        state       <= DATA;
                    end else begin
                        delay <= delay - 1;
                    end
                end

                DATA: begin
                    if (delay == 0) begin
                        if (bit_counter == 6) begin
                            serial_out <= 1'b1;     // stop bit
                            delay      <= CLKS_PER_BIT - 1;
                            state      <= STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                            serial_out  <= data_reg[bit_counter + 1];
                            delay       <= CLKS_PER_BIT - 1;
                        end
                    end else begin
                        delay <= delay - 1;
                    end
                end

                STOP: begin
                    if (delay == 0) begin
                        serial_out <= 1'b1;
                        busy       <= 1'b0;
                        done       <= 1'b1;
                        state      <= IDLE;
                    end else begin
                        delay <= delay - 1;
                    end
                end

                default: begin
                    state      <= IDLE;
                    serial_out <= 1'b1;
                    busy       <= 1'b0;
                    done       <= 1'b0;
                end

            endcase
        end
    end

endmodule
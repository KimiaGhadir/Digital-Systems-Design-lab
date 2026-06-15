module Complex_ALU (
    input clk,
    input reset,
    input signed [7:0] Ar, Ai, Br, Bi,
    input [1:0] opcode,
    input start,
    output reg signed [15:0] Yr, Yi,
    output reg done
);

    reg signed [7:0]  m_a, m_b;
    reg signed [15:0] as_a, as_b;
    reg as_ctrl;

    wire signed [15:0] m_out;
    wire signed [15:0] as_out;

    Multiplier M1 (
        .A(m_a),
        .B(m_b),
        .Out(m_out)
    );

    Adder_Subtractor AS1 (
        .A(as_a),
        .B(as_b),
        .ctrl(as_ctrl),
        .Out(as_out)
    );

    reg signed [15:0] R1, R2, R3, R4;
    reg [2:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= 3'd0;
            done   <= 1'b0;
            Yr     <= 16'd0;
            Yi     <= 16'd0;
            m_a    <= 8'd0;
            m_b    <= 8'd0;
            as_a   <= 16'd0;
            as_b   <= 16'd0;
            as_ctrl <= 1'b0;
            R1     <= 16'd0;
            R2     <= 16'd0;
            R3     <= 16'd0;
            R4     <= 16'd0;
        end
        else begin
            case (state)

                // idle
                3'd0: begin
                    done <= 1'b0;
                    if (start) begin
                        if (opcode == 2'b10)
                            state <= 3'd1;   // complex multiply
                        else
                            state <= 3'd5;   // add/sub
                    end
                end

                // complex multiply: R1 = Ar*Br
                3'd1: begin
                    m_a <= Ar;
                    m_b <= Br;
                    state <= 3'd2;
                end

                // R2 = Ai*Bi
                3'd2: begin
                    R1 <= m_out;
                    m_a <= Ai;
                    m_b <= Bi;
                    state <= 3'd3;
                end

                // R3 = Ar*Bi
                3'd3: begin
                    R2 <= m_out;
                    m_a <= Ar;
                    m_b <= Bi;
                    state <= 3'd4;
                end

                // R4 = Ai*Br
                3'd4: begin
                    R3 <= m_out;
                    m_a <= Ai;
                    m_b <= Br;
                    state <= 3'd5;
                end

                // stage 1 of complex multiply OR simple add/sub
                3'd5: begin
                    if (opcode == 2'b10) begin
                        R4 <= m_out;

                        // Yr = R1 - R2
                        as_a <= R1;
                        as_b <= R2;
                        as_ctrl <= 1'b1;   // subtract
                        state <= 3'd6;
                    end
                    else begin
                        // ADD/SUB real part
                        as_a <= {{8{Ar[7]}}, Ar};
                        as_b <= {{8{Br[7]}}, Br};
                        as_ctrl <= opcode[0]; // 0=add, 1=sub
                        state <= 3'd6;
                    end
                end

                // stage 2 of add/sub OR save Yr for complex multiply
                3'd6: begin
                    Yr <= as_out;

                    if (opcode == 2'b10) begin
                        // Yi = R3 + R4
                        as_a <= R3;
                        as_b <= R4;
                        as_ctrl <= 1'b0;   // add
                        state <= 3'd7;
                    end
                    else begin
                        // imag part for ADD/SUB
                        as_a <= {{8{Ai[7]}}, Ai};
                        as_b <= {{8{Bi[7]}}, Bi};
                        as_ctrl <= opcode[0]; // 0=add, 1=sub
                        state <= 3'd7;
                    end
                end

                // final state
                3'd7: begin
                    Yi <= as_out;
                    done <= 1'b1;
                    state <= 3'd0;   // return to idle so done becomes pulse
                end

                default: begin
                    state <= 3'd0;
                    done  <= 1'b0;
                end

            endcase
        end
    end

endmodule


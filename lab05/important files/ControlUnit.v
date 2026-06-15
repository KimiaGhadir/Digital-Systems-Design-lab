module ControlUnit #(parameter N = 4) (
    input wire clk,
    input wire reset,
    input wire start,
    input wire q0,
    input wire qm1,
    output reg load,
    output reg do_add,
    output reg do_sub,
    output reg do_shift,
    output reg done
);

    parameter IDLE  = 3'b000,
              INIT  = 3'b001,
              CHECK = 3'b010,
              ADD   = 3'b011,
              SUB   = 3'b100,
              SHIFT = 3'b101,
              DONE  = 3'b110;

    reg [2:0] state, next_state;
    reg [4:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE:  next_state = start ? INIT : IDLE;
            INIT:  next_state = CHECK;
            CHECK: begin
                if (qm1 == 1'b0 && q0 == 1'b1) next_state = SUB;
                else if (qm1 == 1'b1 && q0 == 1'b0) next_state = ADD;
                else next_state = SHIFT;
            end
            ADD, SUB: next_state = SHIFT;
            SHIFT: next_state = (count == N - 1) ? DONE : CHECK;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        load = 0; do_add = 0; do_sub = 0; do_shift = 0; done = 0;
        case (state)
            INIT:  load = 1;
            ADD:   do_add = 1;
            SUB:   do_sub = 1;
            SHIFT: do_shift = 1;
            DONE:  done = 1;
            default: ;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) count <= 0;
        else if (state == INIT) count <= 0;
        else if (state == SHIFT) count <= count + 1;
    end

endmodule

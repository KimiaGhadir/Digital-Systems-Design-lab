module Pipelined_Computer (
    input clk,
    input reset,
    output [4:0] pc_out,
    output signed [15:0] Yr_out,
    output signed [15:0] Yi_out,
    output done_out
);

    reg [4:0] pc;
    wire [33:0] instruction;

    reg [33:0] IF_ID_instr;

    reg signed [7:0] Ar, Ai, Br, Bi;
    reg [1:0] opcode;

    reg alu_start;
    wire alu_done;
    wire signed [15:0] alu_Yr, alu_Yi;

    reg busy;

    Instruction_Memory IM (
        .addr(pc),
        .instruction(instruction)
    );

    Complex_ALU ALU (
        .clk(clk),
        .reset(reset),
        .Ar(Ar),
        .Ai(Ai),
        .Br(Br),
        .Bi(Bi),
        .opcode(opcode),
        .start(alu_start),
        .Yr(alu_Yr),
        .Yi(alu_Yi),
        .done(alu_done)
    );

    assign pc_out   = pc;
    assign Yr_out   = alu_Yr;
    assign Yi_out   = alu_Yi;
    assign done_out = alu_done;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc         <= 5'd0;
            IF_ID_instr <= 34'd0;
            Ar         <= 8'sd0;
            Ai         <= 8'sd0;
            Br         <= 8'sd0;
            Bi         <= 8'sd0;
            opcode     <= 2'b00;
            alu_start  <= 1'b0;
            busy       <= 1'b0;
        end else begin
            if (!busy) begin
                // Fetch + Decode + Start execution
                IF_ID_instr <= instruction;

                opcode <= instruction[33:32];
                Ar     <= instruction[31:24];
                Ai     <= instruction[23:16];
                Br     <= instruction[15:8];
                Bi     <= instruction[7:0];

                alu_start <= 1'b1;
                busy <= 1'b1;
            end else begin
                alu_start <= 1'b0;

                if (alu_done) begin
                    pc <= pc + 5'd1;
                    busy <= 1'b0;
                end
            end
        end
    end

endmodule


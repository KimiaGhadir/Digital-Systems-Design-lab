module stack (
	input Clk,
	input RstN,
	input Push,
	input Pop,
	input [3:0] Data_In,
	output reg [3:0] Data_Out,
	output reg Full,
	output reg Empty
);

reg [3:0] stack_pointer;
reg [3:0] mem [7:0];

always @(posedge Clk or negedge RstN) begin
	if (!RstN) begin
		stack_pointer <= 0;
		Empty <= 1;
		Full <= 0;
		Data_Out <= 0;
	end
	else begin
		case ({Push, Pop})
			2'b10: begin 
				if (!Full) begin
					mem[stack_pointer] <= Data_In;
					stack_pointer <= stack_pointer + 1;
					Empty <= 0;
					if (stack_pointer == 4'd7)
						Full <= 1;
				end
			end
			2'b01: begin
				if (!Empty) begin
					Data_Out <= mem[stack_pointer - 1];
					stack_pointer <= stack_pointer - 1;
					Full <= 0;
					if (stack_pointer == 4'd1)
						Empty <= 1;
				end
			end
			2'b11: begin
				if (!Empty && !Full) begin
					Data_Out <= mem[stack_pointer - 1];
					mem[stack_pointer - 1] <= Data_In;
				end
				else if (Empty) begin
					mem[stack_pointer] <= Data_In;
					stack_pointer <= stack_pointer + 1;
					Empty <= 0;
				end
				else if (Full) begin
					Data_Out <= mem[stack_pointer - 1];
					stack_pointer <= stack_pointer - 1;
					Full <= 0;
				end
			end
			default: ;
		endcase
	end
end

endmodule

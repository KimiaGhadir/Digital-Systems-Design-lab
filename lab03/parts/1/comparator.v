module comparator (input [3:0] a, input [3:0] b, output greater, output equal, output less);
    
	 wire [4:0] gr;
	 wire [4:0] eq;
	 wire [4:0] le;
	 
	 assign gr[4] = 1'b0;
	 assign eq[4] = 1'b1;
	 assign le[4] = 1'b0;
	 
	 genvar i;
	 generate
		  for(i = 4; i > 0; i = i - 1)begin: cast
		      castcadable_comparator _cast(
				    .in_gr(gr[i]),
					 .in_eq(eq[i]),
					 .in_le(le[i]),
					 .a(a[i - 1]),
					 .b(b[i - 1]),
					 .out_gr(gr[i - 1]),
					 .out_eq(eq[i - 1]),
					 .out_le(le[i - 1])
				);
		  end
	 endgenerate
	 assign greater = gr[0];
	 assign equal = eq[0];
	 assign less = le[0];
endmodule
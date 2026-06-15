module castcadable_comparator(input in_gr, input in_eq, input in_le, input a, input b, output out_gr, output out_eq, output out_le);
    assign out_gr = in_gr | (in_eq & (a & (~b)));
	 assign out_eq = in_eq & ~(a ^ b);
	 assign out_le = in_le | (in_eq & ((~a) & b));
endmodule
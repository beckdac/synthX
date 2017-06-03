/*
** signed multiplier of 2.16 FP format 2 complement
*/

module signed_mult
	(
		output wire signed [17:0] out,
		input signed [17:0] a,
		input signed [17:0] b
	);

	wire signed [35:0] mult_out;

	assign mult_out = a * b;

	assign out = { mult_out[35], mult_out[32:16] };

endmodule

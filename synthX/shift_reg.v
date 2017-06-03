/*
** Shift register with synchronouse read through write behavior
** 18 bit words in 4k depth
*/

module shift_reg
	(
		input [17:0] in,	// input word
		output [17:0] out,	// output word
		input [11:0] addr,	// address of next read
		input wren,			// write enable
		input clk,			// ram clock
		input aclr			// asyncrhonous clear
	);

	reg [11:0] read_addr;
	reg [17:0] memory [4095:0];

	always @(posedge clk)
		begin
			if (wren)
				memory[addr] <= in;
			else
				read_addr <= addr;
		end
	
	assign out = memory[read_addr];

endmodule

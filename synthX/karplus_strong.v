module karplus_strong
	(
		input clk,
		input aclr,
		input clk_sample,
		input trigger,
		input [11:0] tone,
		input [2:0] cutoff,
		output [15:0] sample
	);

	reg last_trigger;
	reg [11:0] trigger_count;

	// state machine
	// 0 = reset, 1 = read input, 2 = read output
	// 3 = write input, 4 = write, 5 = update ptrs
	// 9 = stop
	reg [3:0] state;
	reg last_clk;

	// decay gain
	wire [17:0] gain;
	assign gain = 18'h0_7EB8; // 0.495

	// shift reg pointers
	reg [11:0] ptr_in, ptr_out;
	// shift reg control
	reg we;
	wire [17:0] sr_data;
	reg [17:0] write_data;
	reg [11:0] addr_reg;

	// registers for math
	reg [17:0] out, in_data, out_data;
	wire [17:0] new_out;

	assign sample = out[17:2];

	// random number generator and low pass filter
	wire x_low_bit;
	reg [30:0] x_rand;
	wire [17:0] new_lopass;
	reg [17:0] lopass;
	assign x_low_bit = x_rand[27] ^ x_rand[30];
	assign new_lopass = lopass + ((( (x_low_bit)?18'h1_0000:18'h3_0000) - lopass)>>>cutoff);

	always @(posedge clk_sample or posedge aclr)
		begin
			if (aclr)
				begin
					x_rand <= 31'h55555555;
					lopass <= 18'h0;
				end
			else
				begin
					x_rand <= { x_rand[29:0], x_low_bit };
					lopass <= new_lopass;
				end
	end

	// main KS state machine
	always @(posedge clk or posedge aclr)
		begin
			if (aclr)
				begin
					ptr_out <= 12'h1;	// start of shift register
					ptr_in <= 12'h0;
					we <= 1'b0;
					state <= 4'd9;		// idle the state machine
					last_clk <=	1'b1;
				end
			else
				begin
					case (state)
						1:
							begin
								addr_reg <= ptr_out;
								we <= 1'b0;
								state <= 4'd2;
							end
						2:
							begin
								out_data <= sr_data;
								addr_reg <= ptr_in;
								we <= 1'b0;
								state <= 4'd3;
							end
						3:
							begin
								in_data <= sr_data;
								state <= 4'd4;
							end
						4:
							begin
								out <= new_out;
								addr_reg <= ptr_in;
								we <= 1'b1;
								// are we in feedback mode or trigger mode
								if (trigger)
									begin
										// debounce the trigger
										if (last_trigger == 0)
											begin
												trigger_count <= 12'd0;
												last_trigger <= 1'd1;
											end
										else if (trigger_count < tone)
											begin
												trigger_count <= trigger_count + 12'd1;
												write_data <= new_lopass;
											end
										// udpate feedback if not triggering
										else
											// trigger is still debouncing so
											// run feedback
											write_data <= new_out;
									end
								else
									begin
										last_trigger <= 1'd0;
										write_data <= new_out;
									end
								state <= 4'd5;
							end
						5:
							begin
								we <= 1'b0;
								if (ptr_in == tone)
									ptr_in <= 12'h0;
								else
									ptr_in <= ptr_in + 12'h1;
								if (ptr_out == tone)
									ptr_out <= 12'h0;
								else
									ptr_out <= ptr_out + 12'h1;
								// end
								state <= 4'd9;
							end
						9:
							begin
								if (clk_sample && last_clk)
									begin
										state <= 4'd1;
										last_clk <= 1'h0;
									end
								else if (!clk_sample)
									begin
										last_clk <= 1'h1;
									end
							end
					endcase
				end
		end

	shift_reg KS1
		(
			.out(sr_data),
			.addr(addr_reg),
			.in(write_data),
			.wren(we),
			.clk(clk),
			.aclr(aclr)
		);

	signed_mult GAINFACTOR
		(
			.out(new_out),
			.a(gain),
			.b((out_data + in_data))
		);

endmodule

module top
	(
		input clk,
		input aclr_,
		input trigger_,
		output i2s_sck,
		output i2s_bck,
		output i2s_lrck,
		output i2s_dout
	);

	wire aclr;
	assign aclr = !aclr_;

	wire trigger;
	assign trigger = !trigger_;

	reg clk_sample = 0;
	reg [3:0] clk_sample_count = 3'd0;

	reg [2:0] cutoff = 3'b011;
	wire [15:0] sample;
	reg [11:0] tone = 12'd699;

	karplus_strong KS1
		(
			.clk(clk),
			.aclr(aclr),
			.clk_sample(clk_sample),
			.trigger(trigger),
			.tone(tone),
			.cutoff(cutoff),
			.sample(sample)
		);

	wire wrreq;
	assign wrreq = clk_sample;
	wire [63:0] lrsample;
	assign lrsample[15:0] = sample;
	assign lrsample[47:32] = sample;
	wire wrfull;

	audio_out I2S
		(
			.clk(clk),
			.aclr(aclr),
			.sample(lrsample),
			.wrreq(wrreq),
			.wrfull(wrfull),
			.lrck(i2s_lrck),
			.bck(i2s_bck),
			.dout(i2s_dout),
			.sck(i2s_sck)
		);

	// sample generator clock
	always @(posedge clk or posedge aclr)
		begin
			if (aclr)
				begin
					clk_sample <= 0;
					clk_sample_count <= 0;
				end
			else
				begin
					if (!wrfull)
						if (clk_sample_count == 3'd3)
							begin
								clk_sample_count <= 0;
								clk_sample = 1'b1;	// raise it for one clock cycle
							end
						else
							begin
								clk_sample_count <= clk_sample_count + 1;
								clk_sample <= 1'b0;
							end
					else
						begin
							clk_sample_count <= clk_sample_count;
							clk_sample <= 1'b0;
						end
				end
		end

endmodule

module karplus_strong_tb();
	localparam CLOCK_PERIOD_NS = 20;

	reg clk = 0;
	always #(CLOCK_PERIOD_NS/2) clk <= !clk;

	reg aclr = 0;

	reg clk_sample = 0;
	reg [3:0] clk_sample_count = 3'd0;

	reg trigger = 0;
	reg [2:0] cutoff = 3'd0;
	wire [15:0] sample;
	reg [11:0] tone = 0;

	karplus_strong MUT
		(
			.clk(clk),
			.aclr(aclr),
			.clk_sample(clk_sample),
			.trigger(trigger),
			.tone(tone),
			.cutoff(cutoff),
			.sample(sample)
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
					if (clk_sample_count == 3'd3)
						begin
							clk_sample_count <= 0;
							clk_sample = !clk_sample;
						end
					else
						begin
							clk_sample_count <= clk_sample_count + 1;
							clk_sample <= clk_sample;
						end
				end
		end

	initial
		begin
			#CLOCK_PERIOD_NS
			aclr <= 1'b1;
			#CLOCK_PERIOD_NS
			aclr <= 1'b0;
			tone <= 12'b010101010101;
			trigger <= 1;
			cutoff <= 3'b011;
			#(CLOCK_PERIOD_NS * 6 * 12'b111010101010)
			trigger <= 0;
			#(CLOCK_PERIOD_NS * 6 * 12'b111010101010)
			$finish;
		end


endmodule

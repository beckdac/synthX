module i2s_tx
	(
		input sclk,
		input aclr,
		output reg lrck,
		output reg dout,
		output reg ready,
		input sample_ready,
		input [63:0] sample
	);

	reg [5:0] bits;
	reg	[31:0] left;
	reg [31:0] right;
	reg sample_valid;

	always @(negedge sclk or posedge aclr)
		begin
			if (aclr)
				bits <= 1'b1;
			else if (bits == 32)
				bits <= 1'b1;
			else
				bits <= bits + 1'b1;
		end

	// load the next sample at the end
	always @(negedge sclk or posedge aclr)
		begin
			if (aclr)
				begin
					left <= 32'd0;
					right <= 32'd0;
				end
			else if (bits == 32 && lrck)
				begin
					if (sample_valid)
						begin
							left <= sample[63:32];
							right <= sample[31:0];
						end
					else
						begin
							left <= 32'd0;
							right <= 32'd0;
						end
				end
		end

	// assert the ready flag for one clock cycle to accept the next sample
	// into the internal buffer (sample) - 
	always @(negedge sclk or posedge aclr)
		begin
			if (aclr)
				begin
					ready <= 1;
				end
			else if (bits == 32 && lrck)
				begin
					ready <= 1;
				end
			else
				begin
					ready <= 0;
				end
		end

	always @(negedge sclk or posedge aclr)
		begin
			if (aclr)
				sample_valid <= 0;
			else if (bits == 32 && lrck)
				sample_valid <= sample_ready;
			else
				sample_valid <= sample_valid;
		end

	always @(negedge sclk or posedge aclr)
		begin
			if (aclr)
				begin
					lrck <= 1;
				end
			else if (bits == 32)
				begin
					lrck <= !lrck;
				end
		end

	always @(negedge sclk)
		begin
			dout <= lrck ? right[32 - bits] : left[32 - bits];
		end

endmodule

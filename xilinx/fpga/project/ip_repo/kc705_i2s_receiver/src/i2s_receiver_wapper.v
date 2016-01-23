`timescale 1 ns / 1 ps

module i2s_receiver_wapper #(
		parameter integer ID_WIDTH = 5,
		parameter integer I2S_RECEIVER_NUM = 32,

		parameter integer C_M_AXIS_TDATA_WIDTH = 32
	)
	(
		input wire rst_n,
		input wire clk,

		input wire [I2S_RECEIVER_NUM - 1 : 0] bclk,
		input wire [I2S_RECEIVER_NUM - 1 : 0] lrclk,
		input wire [I2S_RECEIVER_NUM - 1 : 0] sdata,
		//output wire [I2S_RECEIVER_NUM - 1 : 0] i2s_din,

		output wire wclk,
		output reg wen = 0,
		output reg [C_M_AXIS_TDATA_WIDTH - 1 : 0] wdata = 0,

		output wire [I2S_RECEIVER_NUM - 1 : 0] local_r_ready,
		output wire [I2S_RECEIVER_NUM - 1 : 0] local_error_full,
		output wire [I2S_RECEIVER_NUM - 1 : 0] local_error_empty
	);
	
	localparam integer I2S_DATA_BIT_WIDTH = 24;
	localparam integer FIFO_DATA_WIDTH = 16;

	reg [I2S_RECEIVER_NUM - 1 : 0] local_r_enable;

	wire [FIFO_DATA_WIDTH - 1 : 0] local_rdata [I2S_RECEIVER_NUM - 1:0];

	assign wclk = clk;

	genvar i;
	generate for (i = 0; i < I2S_RECEIVER_NUM; i = i + 1)
		begin : i2s_instance

			localparam integer id = i;

			i2s_receiver #(
					.C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
					.I2S_DATA_BIT_WIDTH(I2S_DATA_BIT_WIDTH),
					.FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
					.ID(id),
					.ID_WIDTH(5)
				) receiver_inst (
					.clk(clk),
					.rst_n(rst_n),

					.bclk(bclk[i]),
					.lrclk(lrclk[i]),
					.sdata(sdata[i]),

					.r_enable(local_r_enable[i]),
					.rdata(local_rdata[i]),

					.r_ready(local_r_ready[i]),
					.error_full(local_error_full[i]),
					.error_empty(local_error_empty[i])
				);
		end
	endgenerate


	localparam integer LOCAL_BULK_OF_DATA = 15;

	integer i2s_index = 0;
	integer cache_state = 0;
	integer local_rdata_count = 0;

	always @(posedge clk) begin
		if(rst_n == 0) begin
			local_r_enable <= 0;
			wen <= 0;

			i2s_index <= 0;
			local_rdata_count <= 0;

			wdata <= 0;

			cache_state <= 0;
		end
		else begin
			local_r_enable <= 0;
			wen <= 0;

			case(cache_state)
				0: begin

					if(local_r_ready[i2s_index] == 1) begin
						local_r_enable[i2s_index] <= 1;

						local_rdata_count <= 0;

						cache_state <= 1;
					end
					else begin
						if((i2s_index >= 0) && (i2s_index < I2S_RECEIVER_NUM - 1)) begin
							i2s_index <= i2s_index + 1;
						end
						else begin
							i2s_index <= 0;
						end
					end
				end
				1: begin
					if((local_rdata_count >= 0) && (local_rdata_count < LOCAL_BULK_OF_DATA)) begin
						if(local_rdata_count != LOCAL_BULK_OF_DATA - 1) begin
							local_r_enable[i2s_index] <= 1;
						end

						wen <= 1;
						wdata <= {{(FIFO_DATA_WIDTH){1'b0}}, local_rdata[i2s_index]};


						local_rdata_count <= local_rdata_count + 1;
					end
					else begin
						if((i2s_index >= 0) && (i2s_index < I2S_RECEIVER_NUM - 1)) begin
							i2s_index <= i2s_index + 1;
						end
						else begin
							i2s_index <= 0;
						end

						cache_state <= 0;

					end
				end
				default: begin
				end
			endcase
		end
	end
endmodule

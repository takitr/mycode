`timescale 1ns/1ns

module i2s_slave_interface #
	(
		parameter integer I2S_DATA_BIT_WIDTH = 24
	)
	(
		input wire rst_n,
		input wire bclk,
		input wire lrclk,
		input wire sdata,
		//output wire i2s_din,
		output reg [I2S_DATA_BIT_WIDTH : 0] i2s_received_data = 0,
		output reg s_data_valid = 0
	);



	reg lrstate = 0;
	reg [8 - 1 : 0] count = I2S_DATA_BIT_WIDTH;

	always @(posedge bclk) begin
		if(rst_n == 0'b0) begin
			i2s_received_data[I2S_DATA_BIT_WIDTH] <= lrclk;
			s_data_valid <= 0;
			lrstate <= lrclk;
			count <= I2S_DATA_BIT_WIDTH - 1;
		end
		else begin
			s_data_valid <= 0;
			
			if(lrstate != lrclk) begin
				i2s_received_data[I2S_DATA_BIT_WIDTH] <= lrclk;
				lrstate <= lrclk;
				count <= I2S_DATA_BIT_WIDTH - 1;
			end
			else begin
				i2s_received_data[count] <= sdata;

				if((count > 0) && (count <= I2S_DATA_BIT_WIDTH - 1)) begin
					count <= count - 1;
				end
				else if(count == 0) begin//count == 0
					s_data_valid <= 1;
					count <= I2S_DATA_BIT_WIDTH;
				end
				else begin//count == I2S_DATA_BIT_WIDTH
				end
			end
		end
	end
endmodule

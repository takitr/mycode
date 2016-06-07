`timescale 1ns / 1ps
`include "iic_def.v"

module iic_master #
	(
		// Debounce SCL and SDA over this many clock ticks
		// The rise time of SCL and SDA can be up to 1000nS (in standard mode)
		// so it is essential to debounce the inputs.
		// The spec requires 0.05V of hysteresis, but in practise
		// simply debouncing the inputs is sufficient
		// I2C spec requires suppresion of spikes of 
		// maximum duration 50nS, so this debounce time should be greater than 50nS
		// Also increases data hold time and decreases data setup time
		// during an I2C read operation
		// 10 ticks = 208nS @ 48MHz
		parameter integer DEB_I2C_LEN  = 10,

		// Delay SCL for use as internal sampling clock
		// Using delayed version of SCL to ensure that 
		// SDA is stable when it is sampled.
		// Not entirely citical, as according to I2C spec
		// SDA should have a minimum of 100nS of set up time
		// with respect to SCL rising edge. But with the very slow edge 
		// speeds used in I2C it is better to err on the side of caution.
		// This delay also has the effect of adding extra hold time to the data
		// with respect to SCL falling edge. I2C spec requires 0nS of data hold time.
		// 10 ticks = 208nS @ 48MHz
		parameter integer SCL_DEL_LEN = 10
	)
	(
		// Users to add ports here
		input wire request,

		input wire [7 : 0] wcount,
		output wire wen,
		output wire [7 : 0] wdata,
		output wire [7 : 0] waddr,

		input wire [7 : 0] rcount,
		output wire ren,
		input wire [7 : 0] rdata,
		output wire [7 : 0] raddr,

		input wire [7 : 0] slave_addr,

		output reg iic_ready = 0,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of iic-slave
		input wire clk,
		input wire rst_n,

		inout wire sda,
		output reg scl = 1
	);

	// local wires and regs
	wire sda_in;
	wire sda_out_en;
	wire sda_out;

	assign sda = (sda_out_en == 1) ? sda_out : 1'bz;
	assign sda_in = sda;

	localparam integer SCL_LEVEL_COUNT = DEB_I2C_LEN * 5;

	integer scl_level_count = SCL_LEVEL_COUNT;
	always @(posedge clk) begin
		if(rst_n == 0) begin
			scl <= 1;
			scl_level_count <= SCL_LEVEL_COUNT;
		end
		else begin
			if(scl_level_count > 1) begin
				scl_level_count <= scl_level_count - 1;
			end
			else begin
				scl_level_count <= SCL_LEVEL_COUNT;
				scl <= ~scl;
			end
		end
	end


	// debounce sda
	reg [DEB_I2C_LEN - 1 : 0] sda_pipe = {DEB_I2C_LEN{1'b1}};
	reg sda_deb = 1'b1;
	always @(posedge clk) begin
		if(rst_n == 1'b0) begin
			sda_pipe <= {DEB_I2C_LEN{1'b1}};
			sda_deb <= 1'b1;
		end
		else begin
			if(&sda_pipe[DEB_I2C_LEN - 1 : 1] == 1'b1) begin
				sda_deb <= 1'b1;
			end
			else if(|sda_pipe[DEB_I2C_LEN - 1 : 1] == 1'b0) begin
				sda_deb <= 1'b0;
			end

			sda_pipe <= {sda_pipe[DEB_I2C_LEN - 2 : 0], sda_in};
		end
	end

	// delay scl
	// scl_delayed is used as a delayed sampling clock
	// sda_delayed is only used for start stop detection
	// Because sda hold time from scl falling is 0nS
	// sda must be delayed with respect to scl to avoid incorrect
	// detection of start/stop at scl falling edge. 
	reg [SCL_DEL_LEN - 1 : 0] scl_delayed = {SCL_DEL_LEN{1'b1}};
	always @(posedge clk) begin
		if(rst_n == 1'b0) begin
			scl_delayed <= {SCL_DEL_LEN{1'b1}};
		end
		else begin
			scl_delayed <= {scl_delayed[SCL_DEL_LEN - 2 : 0], scl};
		end
	end

	reg [7 : 0] count = 0;


	wire fifo_wen;
	assign wen = fifo_wen;
	wire [7 : 0] fifo_wdata;
	assign wdata = fifo_wdata;
	assign waddr = wcount - count;

	wire fifo_ren;
	assign ren = fifo_ren;
	wire [7 : 0] fifo_rdata;
	assign fifo_rdata = rdata;
	assign raddr = rcount - count;

	reg start = 0;
	wire stop_request;
	wire [8 : 0] status;
	reg stop = 0;
	integer state = 0;
	always @(posedge clk) begin
		if(rst_n == 0) begin
			iic_ready <= 0;

			count <= 0;

			start <= 0;

			stop <= 0;

			state <= 0;
		end
		else begin
			iic_ready <= 0;

			start <= 0;

			stop <= 0;

			case(state)
				0: begin
					if(request == 1) begin
						if(slave_addr[0] == 1) begin
							count <= wcount;
						end
						else begin
							count <= rcount;
						end

						state <= 1;
					end
					else begin
						iic_ready <= 1;
					end
				end
				1: begin
					if(scl == 1) begin

						state <= 2;
					end
					else begin
					end
				end
				2: begin
					if(scl == 0) begin
						start <= 1;

						state <= 3;
					end
					else begin
					end
				end
				3: begin
					if(stop_request == 1) begin//scl == 1
						if(status == `I2C_NO_ERR) begin
							if(count <= 0) begin
								stop <= 1;

								state <= 4;
							end
							else begin
							end
						end
						else begin
							stop <= 1;

							state <= 4;
						end
					end
					else begin
					end

					if(count > 0) begin
						if(fifo_wen == 1) begin//received last byte
							count <= count - 1;
						end
						else if(fifo_ren == 1)begin//need send last byte
							count <= count - 1;
						end
						else begin
						end
					end
					else begin
					end
				end
				4: begin
					if(scl == 0) begin

						state <= 0;
					end
					else begin
					end
				end
				default: begin
				end
			endcase
		end
	end

	iic_master_interface #
		(
		)
		iic_master_interface_inst (
			.clk(clk),
			.rst_n(rst_n),

			.scl_out(scl),
			.scl_out_delay(scl_delayed[SCL_DEL_LEN - 1]),

			.sda_in(sda_pipe[DEB_I2C_LEN - 1]),
			.sda_out_en(sda_out_en),
			.sda_out(sda_out),

			.slave_addr(slave_addr),

			.fifo_wen(fifo_wen),
			.fifo_wdata(fifo_wdata),

			.fifo_ren(fifo_ren),
			.fifo_rdata(fifo_rdata),

			.start(start),

			.stop_request(stop_request),
			.status(status),
			.stop(stop)
		);
endmodule

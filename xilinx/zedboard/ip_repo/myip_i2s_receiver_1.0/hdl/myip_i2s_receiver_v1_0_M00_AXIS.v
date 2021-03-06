`timescale 1 ns / 1 ps

module myip_i2s_receiver_v1_0_M00_AXIS #
	(
		// Users to add parameters here
		parameter integer I2S_DATA_BIT_WIDTH = 24,
		parameter integer NUMBER_OF_OUTPUT_WORDS = 8,

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH = 32,
		// Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.
		parameter integer C_M_START_COUNT = 32
	)
	(
		// Users to add ports here
		input wire i2s_receiver_bclk,
 		input wire i2s_receiver_lrclk,
 		input wire i2s_receiver_sdata,
		output wire read_enable,
		output wire output_ready,
		output wire buffer_full_error,
		output wire buffer_empty_error,

		// User ports ends
		// Do not modify the ports beyond this line

		// Global ports
		input wire M_AXIS_ACLK,
		//
		input wire M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
		output wire M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire M_AXIS_TREADY
	);
	//Total number of output data.
	// Total number of output data
	// function called clogb2 that returns an integer which has the
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
		begin
			for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
				bit_depth = bit_depth >> 1;
		end
	endfunction

	// WAIT_COUNT_BITS is the width of the wait counter.
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT-1);

	// bit_num gives the minimum number of bits needed to address 'depth' size of FIFO.
	localparam bit_num = clogb2(NUMBER_OF_OUTPUT_WORDS);

	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	localparam [1:0] IDLE = 2'b00, // This is the initial/idle state

	INIT_COUNTER = 2'b01, // This state initializes the counter, ones
															// the counter reaches C_M_START_COUNT count,
															// the state machine changes state to INIT_WRITE
	SEND_STREAM = 2'b10; // In this state the
															// stream data is output through M_AXIS_TDATA
	// State variable
	reg [1:0] mst_exec_state = IDLE;
	// Example design FIFO read pointer
	reg [bit_num-1:0] read_pointer;

	// AXI Stream internal signals
	//wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	reg [WAIT_COUNT_BITS-1 : 0] count;
	//streaming data valid
	wire axis_tvalid;
	//streaming data valid delayed by one clock cycle
	reg axis_tvalid_delay = 0;
	//Last of the streaming data
	wire axis_tlast;
	//Last of the streaming data delayed by one clock cycle
	reg axis_tlast_delay = 0;
	//FIFO implementation signals
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] stream_data_out = 0;
	//wire read_enable;
	//The master has issued all the streaming data stored in FIFO
	reg tx_done;

	wire [C_M_AXIS_TDATA_WIDTH - 1 : 0] rdata;


	// I/O Connections assignments

	assign M_AXIS_TVALID = axis_tvalid_delay;
	assign M_AXIS_TDATA = stream_data_out;
	assign M_AXIS_TLAST = axis_tlast_delay;
	assign M_AXIS_TSTRB = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};


	// Control state machine implementation
	always @(posedge M_AXIS_ACLK)
	begin
		if (!M_AXIS_ARESETN)
		// Synchronous reset (active low)
			begin
				mst_exec_state <= IDLE;
			end
		else
			case (mst_exec_state)
				IDLE:
					// The slave starts accepting tdata when
					// there tvalid is asserted to mark the
					// presence of valid streaming data
					//if ( count == 0 )
					// begin
						if(output_ready == 1) begin
							count <= 0;
							mst_exec_state <= INIT_COUNTER;
						end
					// end
					//else
					// begin
					// mst_exec_state	<= IDLE;
					// end

				INIT_COUNTER:
					// The slave starts accepting tdata when
					// there tvalid is asserted to mark the
					// presence of valid streaming data
					if ( count == C_M_START_COUNT - 1 )
						begin
							mst_exec_state <= SEND_STREAM;
						end
					else
						begin
							count <= count + 1;
							mst_exec_state <= INIT_COUNTER;
						end

				SEND_STREAM:
					// The example design streaming master functionality starts
					// when the master drives output tdata from the FIFO and the slave
					// has finished storing the S_AXIS_TDATA
					if (tx_done)
						begin
							mst_exec_state <= IDLE;
						end
					else
						begin
							mst_exec_state <= SEND_STREAM;
						end
			endcase
	end


	//tvalid generation
	//axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	//number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
	assign axis_tvalid = ((mst_exec_state == SEND_STREAM) && (read_pointer < NUMBER_OF_OUTPUT_WORDS));

	// AXI tlast generation
	// axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1
	// (0 to NUMBER_OF_OUTPUT_WORDS-1)
	assign axis_tlast = (read_pointer == NUMBER_OF_OUTPUT_WORDS-1);


	// Delay the axis_tvalid and axis_tlast signal by one clock cycle
	// to match the latency of M_AXIS_TDATA
	always @(posedge M_AXIS_ACLK)
	begin
		if (!M_AXIS_ARESETN)
			begin
				axis_tvalid_delay <= 1'b0;
				axis_tlast_delay <= 1'b0;
			end
		else
			begin
				axis_tvalid_delay <= axis_tvalid;
				axis_tlast_delay <= axis_tlast;
			end
	end


	//read_pointer pointer
	always@(posedge M_AXIS_ACLK)
	begin
		if(!M_AXIS_ARESETN)
			begin
				read_pointer <= 0;
				tx_done <= 1'b0;
			end
		else
			if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1)
				begin
					if (read_enable)
						// read pointer is incremented after every read from the FIFO
						// when FIFO read signal is enabled.
						begin
							read_pointer <= read_pointer + 1;
							//tx_done <= 1'b0;
						end
				end
			else if (read_pointer == NUMBER_OF_OUTPUT_WORDS)
				begin
					// tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
					// has been out.
					if(mst_exec_state == IDLE) begin
						tx_done <= 1'b0;
						read_pointer <= 0;
					end
					else begin
						tx_done <= 1'b1;
					end
				end
	end


	//FIFO read enable generation

	assign read_enable = M_AXIS_TREADY && axis_tvalid;
//	assign output_ready = 1;

	// Streaming output data is read from FIFO
	always @( posedge M_AXIS_ACLK )
	begin
		if(!M_AXIS_ARESETN)
			begin
				stream_data_out <= 0;
			end
		else if (read_enable)// && M_AXIS_TSTRB[byte_index]
			begin
//				stream_data_out <= read_pointer + 32'b1;
				stream_data_out <= rdata;
			end
	end

	// Add user logic here
	////////////////////////////////////////////////////////////////////////////////////////////////


	wire s_data_valid;

	wire [C_M_AXIS_TDATA_WIDTH - 1:0] wdata;
	wire [I2S_DATA_BIT_WIDTH:0] i2s_received_data;

 	receive_data_from_i2s #
		(
			.I2S_DATA_BIT_WIDTH(I2S_DATA_BIT_WIDTH)
		)
		receiver
		(
			.rst(M_AXIS_ARESETN),
			.bclk(i2s_receiver_bclk),
			.lrclk(i2s_receiver_lrclk),
			.sdata(i2s_receiver_sdata),
			.i2s_received_data(i2s_received_data),
			.s_data_valid(s_data_valid)
		);

	assign wdata = {i2s_received_data[I2S_DATA_BIT_WIDTH], {(C_M_AXIS_TDATA_WIDTH - 1 - I2S_DATA_BIT_WIDTH){1'b0}}, i2s_received_data[I2S_DATA_BIT_WIDTH - 1 : 0]};


	my_fifo #
		(
			.DATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
			.NUMBER_OF_OUTPUT_WORDS(NUMBER_OF_OUTPUT_WORDS)
		)
		xiaofei_fifo
		(
			.rst(M_AXIS_ARESETN),
			.wclk(s_data_valid),
			.rclk(M_AXIS_ACLK),
			.wdata(wdata),
			.rdata(rdata),
			.read_enable(read_enable),//stay 3 cycles
			.output_ready(output_ready),
			.buffer_full_error(buffer_full_error),
			.buffer_empty_error(buffer_empty_error)
		);
	////////////////////////////////////////////////////////////////////////////////////////////////
	// User logic ends

endmodule

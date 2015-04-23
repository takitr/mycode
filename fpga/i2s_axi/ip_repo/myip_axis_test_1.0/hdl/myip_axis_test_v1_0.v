
`timescale 1 ns / 1 ps

        module myip_axis_test_v1_0 #
        (
                // Users to add parameters here

                // User parameters ends
                // Do not modify the parameters beyond this line


                // Parameters of Axi Master Bus Interface M00_AXIS
                parameter integer C_M00_AXIS_TDATA_WIDTH        = 32,
                parameter integer C_M00_AXIS_START_COUNT        = 32
        )
        (
                // Users to add ports here
                wire [3:0] read_pointer,

                // User ports ends
                // Do not modify the ports beyond this line


                // Ports of Axi Master Bus Interface M00_AXIS
                input wire  m00_axis_aclk,
                input wire  m00_axis_aresetn,
                output wire  m00_axis_tvalid,
                output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
                output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
                output wire  m00_axis_tlast,
                input wire  m00_axis_tready
        );
// Instantiation of Axi Bus Interface M00_AXIS
        myip_axis_test_v1_0_M00_AXIS # ( 
                .C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
                .C_M_START_COUNT(C_M00_AXIS_START_COUNT)
        ) myip_axis_test_v1_0_M00_AXIS_inst (
                .read_pointer(read_pointer),

                .M_AXIS_ACLK(m00_axis_aclk),
                .M_AXIS_ARESETN(m00_axis_aresetn),
                .M_AXIS_TVALID(m00_axis_tvalid),
                .M_AXIS_TDATA(m00_axis_tdata),
                .M_AXIS_TSTRB(m00_axis_tstrb),
                .M_AXIS_TLAST(m00_axis_tlast),
                .M_AXIS_TREADY(m00_axis_tready)
        );

        // Add user logic here

        // User logic ends

        endmodule

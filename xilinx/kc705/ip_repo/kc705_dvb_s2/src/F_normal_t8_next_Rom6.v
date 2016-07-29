
`timescale 1ns / 1ps
module F_normal_t8_next_Rom6(
input	          							clk_1x,
input	          							rst_n,
//////////////////////////////////////////////////////////////
input										rd_en,
input				[4:0]				rdaddr,
output		reg			[127:0]				rd_q
);

always @(posedge clk_1x)begin
	if(~rst_n)begin
		rd_q <= 128'b0;
	end
	else if(rd_en == 1'b1)begin
		case(rdaddr)
			5'h0f: rd_q <= 128'b10001000000111011110110100000100010100001111101001110111010011001010111010010000110010000111100000000010101101010011101110101010;
			5'h0e: rd_q <= 128'b10110000110010100011111011010011011101011110110001100001001001000100011010011010101111111101101100101011101101001111100010011100;
			5'h0d: rd_q <= 128'b10101111100011001001010001100001001100001101000011011001110000111001111011010111011000011000101100011011111101101101000111011001;
			5'h0c: rd_q <= 128'b00111001010110001000111110010000000000010010101101010000101110010101011001000001111000111100001111000111111011011100100100011100;
			5'h0b: rd_q <= 128'b01111011011000111001100111110000110111010001001000100001011010101011111000101110010111100101100111111001101111100110100011010000;
			5'h0a: rd_q <= 128'b10100100101000100110000011001101000111001110011011110101100001101001111000011110000001000000011000000001010110111011001001001011;
			5'h09: rd_q <= 128'b01111111101001000000000010100100010001101001110111101001101100100001011110000101001110101100000101101101101100100010001111101010;
			5'h08: rd_q <= 128'b11011010000011101100100010101110100000101010000100011001011101101110011011010111010110000110111011101111100010011000111110011000;
			5'h07: rd_q <= 128'b00010111000100001011010011011110101100011011111100000101000100111110101010000101011101011000000101011110000100010101101110001011;
			5'h06: rd_q <= 128'b11000001010000100110001011000000101011001101110110010000000101100110000111101100101101110111100101101101000110111111100100100111;
			5'h05: rd_q <= 128'b01000001001111010001101001100101011011110001111010001111001101001110011000110001011000000011110100110100000010000011001010101101;
			5'h04: rd_q <= 128'b11000100111001101110000111101011100100001100110001011000100111101110000111111000111010111101101010011101010011100101010011001111;
			5'h03: rd_q <= 128'b00010011010101000011111101001100001100100011111101101101001011111001010011100001011000010100110110111011101010010110000100010001;
			5'h02: rd_q <= 128'b01011110100100010111000101011001011100011001100111000011001110000110111101100001101110011100110010010011101101011010100010110011;
			5'h01: rd_q <= 128'b00110111101111100110000111111011101100010011101110100010101001000100010010011001011011001100000101010100001001010101011111100110;
			5'h00: rd_q <= 128'b10111011100100001100000001010100100001011001001101110010111101001110000001000001011001110001001100001010100111010000000111110010;
		default:rd_q <= 128'b0;
		endcase
	end
end

endmodule
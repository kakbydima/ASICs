`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:09:48 01/08/2021 
// Design Name: 
// Module Name:    mock_data_pipein 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//Triangle wave generator 
module mock_data_pipein(
	RST,
	CLK100M,
	CLK,
	
	fifo_rd,
	fifo_out,
	rd_data_count,
	fifo_dout_valid
	
    );
parameter batchsize = 10;
parameter batchnum = 32;
parameter doutsize = batchnum*batchsize;

input RST;
input CLK100M;
input CLK;
input fifo_rd;
output wire [32-1:0] fifo_out;
output wire [7:0] rd_data_count;
output wire fifo_dout_valid;

wire [doutsize-1:0] DOUT;
wire DATA_CLK;
wire data_ready; //gives high when output from datagen is ready
wire fifo_wr;
wire [32-1:0] DATAMUXED;

data_clk_gen clk_gen(
	.clk_rst(RST),
	.clk(CLK100M),
	.data_clk(DATA_CLK),
	.data_ready(data_ready)
    );
	 
trian_data_gen datagen(
	.RST(RST),
	.CLK(DATA_CLK),
	.DOUT(DOUT)
    );
	 
MUX_i320_o32 mux_unit(
	.RST(RST),
	.CLK(CLK100M),
	.DOUT(DOUT),
	.data_ready(data_ready),
	.DATAMUXED(DATAMUXED),
	.FIFO_WR(fifo_wr)
); 	 

fifo_w32_256_r32 fifo2ram (
  .rst(RST), // input rst
  .wr_clk(CLK100M), // input wr_clk
  .rd_clk(CLK), // input rd_clk
  .din(DATAMUXED), // input [31 : 0] din
  .wr_en(fifo_wr), // input wr_en
  .rd_en(fifo_rd), // input rd_en
  .dout(fifo_out), // output [31 : 0] dout
  .full(), // output full
  .empty(), // output empty
  .valid(fifo_dout_valid), // output valid
  .rd_data_count(rd_data_count), // output [7 : 0] rd_data_count
  .wr_data_count() // output [7 : 0] wr_data_count
  
);







endmodule

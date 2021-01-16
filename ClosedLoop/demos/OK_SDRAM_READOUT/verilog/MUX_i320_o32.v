`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:29:52 01/08/2021 
// Design Name: 
// Module Name:    MUX_i320_o32 
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
module MUX_i320_o32(
	RST,
	CLK,
	DOUT,
	data_ready,
	DATAMUXED,
	FIFO_WR
    );

parameter batchsize = 32;
parameter batchnum = 10;
input RST;
input CLK;
input [batchnum*batchsize-1:0] DOUT;
input data_ready;
output reg [batchsize-1:0] DATAMUXED;
output reg FIFO_WR;
reg data_ready_old;
reg [batchnum*batchsize-1:0] DOUTbuf;
reg [1:0] state;
reg [4:0] cnt;
parameter IDLE=0, LOAD=1, MUX=2; 

always @ (posedge CLK or posedge RST) 
begin
	if (RST)
	begin
		DATAMUXED<=0;
		FIFO_WR<=0;
		DOUTbuf<=0;
		state<=IDLE;
		cnt<=0;
	end
	else
	begin
		case (state)
		IDLE:
		begin
			data_ready_old<=data_ready;
			if ((data_ready_old==0)&&(data_ready==1))
			begin
				state<=LOAD;
			end
			else
			begin
				DATAMUXED<=0;
				FIFO_WR<=0;
				DOUTbuf<=0;
				state<=IDLE;
				cnt<=0;
			end
		end
		LOAD:
		begin
			DOUTbuf<= DOUT;
			state <= MUX;
		end
		MUX:
		begin
			if (cnt<10)
			begin
				cnt<=cnt+1;
				DATAMUXED<=DOUT[cnt*batchsize+:batchsize];
				FIFO_WR<=1;
				
			end
			else
			begin
				cnt<=0;
				state<=IDLE;
				DATAMUXED<=0;
				FIFO_WR<=0;
			end
		end
		default: state<=IDLE;
		endcase
		
	end
end


endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:08:05 01/08/2021 
// Design Name: 
// Module Name:    trian_data_gen 
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
module trian_data_gen(
	RST,
	CLK,
	DOUT
    );
parameter batchsize = 10;
parameter batchnum = 32;
parameter doutsize = batchnum*batchsize;

parameter INCREASE=0,DECREASE=1;
input RST;
input CLK;
output reg [doutsize-1:0] DOUT;

reg state;

integer i;

wire [batchsize:0] maxdout;
assign maxdout=(2**batchsize)-1;

always @(posedge CLK or posedge RST)
begin
	if (RST)
	begin
		DOUT <=0; 
		state <= INCREASE;
	end
	else
	begin
		case (state)
		INCREASE:
		begin
			if (DOUT[batchsize-1:0]<maxdout-1)
			begin
				for(i=0; i<batchnum; i=i+1)
				  DOUT[i*batchsize+:batchsize] <= DOUT[i*batchsize+:batchsize]+1;
				state<=INCREASE;
			end
			else
			begin
				for(i=0; i<batchnum; i=i+1)
				  DOUT[i*batchsize+:batchsize] <= DOUT[i*batchsize+:batchsize]+1;
				state<=DECREASE;
			end
		end
		DECREASE:
		begin
			if (DOUT[batchsize-1:0]>1)
			begin
				for(i=0; i<batchnum; i=i+1)
				  DOUT[i*batchsize+:batchsize] <= DOUT[i*batchsize+:batchsize]-1;
				state<=DECREASE;
			end
			else
			begin
				for(i=0; i<batchnum; i=i+1)
				  DOUT[i*batchsize+:batchsize] <= DOUT[i*batchsize+:batchsize]-1;
				state<=INCREASE;
			end
		end
		default:  state<=INCREASE;
		endcase
	end
end
endmodule

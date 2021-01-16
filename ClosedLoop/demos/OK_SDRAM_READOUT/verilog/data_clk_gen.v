`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:27 01/08/2021 
// Design Name: 
// Module Name:    data_clk_gen 
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
module data_clk_gen(
	clk_rst,
	clk,
	data_clk,
	data_ready
    );

input clk_rst;
input clk;
output reg data_clk;
reg [15:0] clkcnt;
output reg data_ready;

parameter clk_div=20000; // 


always @(posedge clk or posedge clk_rst)
		begin
			if (clk_rst)
			begin
				data_clk<=0;
				clkcnt<=0;
			end
			else
			begin
				if (clkcnt<clk_div)
					begin
						clkcnt<=clkcnt+1;
					end
					else
					begin
						data_clk<=~data_clk;
						clkcnt<=0;
					end
					data_ready<=data_clk;
			end
		end
endmodule

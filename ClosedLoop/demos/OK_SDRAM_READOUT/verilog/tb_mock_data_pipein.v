`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:37:58 01/08/2021
// Design Name:   mock_data_pipein
// Module Name:   C:/Users/Professional/Desktop/Work/W_INTAN/FPGA_test/SDRAM_FSM_ex2/tb_mock_data_pipein.v
// Project Name:  SDRAM_FSM_ex2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mock_data_pipein
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_mock_data_pipein;

	// Inputs
	reg RST;
	reg CLK;
	reg fifo_rd;

	// Outputs
	wire [31:0] fifo_out;
	wire [7:0] rd_data_count;

	// Instantiate the Unit Under Test (UUT)
	mock_data_pipein uut (
		.RST(RST), 
		.CLK(CLK), 
		.fifo_rd(fifo_rd), 
		.fifo_out(fifo_out), 
		.rd_data_count(rd_data_count)
	);

	initial begin
		// Initialize Inputs
		RST = 0;
		CLK = 0;
		fifo_rd=0;

		// Wait 100 ns for global reset to finish
		#100;
		RST = 1;
		#100;
		RST = 0;
	end
	always
	begin
		#2 CLK=~CLK;
	end
	always @(posedge CLK)
	begin
		if (rd_data_count>10)
		begin
			fifo_rd<=1;
		end
		else
		begin
			fifo_rd<=0;
		end
	end
endmodule


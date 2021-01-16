//Verilog HDL for "intanW_dima_rf", "data_transfer_ctrl" "functional"



module SRAM_check_behav_v2_full( 
CLK,
RST,
Q1,
Q2,
CEB1,
CEB2,
ADD1,
ADD2,
CMD1,
CMD2,
DIN1,
DIN2,



MSB_DATA,
LSB_DATA,
DOUT,
WRITE_DONE,
READ_DONE,

state,
);

parameter write_num = 512;

input CLK;
input RST;
//READOUT ports
input [7:0] Q1;
input [7:0] Q2;
//chip enable(low) 
output reg CEB1;
output reg CEB2;
//write(low)/read(high)
output reg CMD1;
output reg CMD2;
output reg [9:0] ADD1; //write it on negedge
// read from Q2 port 
output reg [9:0] ADD2; 
// write to DIN port 
output reg [7:0] DIN1;
output reg [7:0] DIN2;

reg [15:0] cnt;
reg [15:0] rcnt;
output reg [7:0] MSB_DATA;
output reg [7:0] LSB_DATA;
output reg [15:0] DOUT;
output reg WRITE_DONE;
output reg READ_DONE;
reg [1:0] div_cnt;
reg  clkd;
reg dac_sample;

output reg [2:0] state;
parameter 
	IDLE 		= 0,
	WRITE_LSB 	= 1,
	WRITE_MSB 	= 2,
	WRITE_DONE_ST	= 3,
	SET_READ_LSB 	= 4,
	READ_LSB	= 5,
	SET_READ_MSB 	= 6,
	READ_MSB 	= 7;
  
always @(negedge CLK or posedge RST)
begin
	if (RST)
	begin
		CEB1 		<= 1'b1;
		CEB2 		<= 1'b1;
		CMD1 		<= 1'b1;
		CMD2 		<= 1'b1;
		ADD1 		<= -1;
		ADD2 		<= -1;
		DIN1 		<= 0;
		DIN2 		<= 0;
		cnt  		<= 1;
		rcnt  		<= 1;
		state  		<= IDLE;
		WRITE_DONE 	<= 0;
		READ_DONE 	<= 0;
		LSB_DATA	<= 0;
		MSB_DATA	<= 0;
	end
	else
	begin
		case (state)
		IDLE:
		begin
			if (READ_DONE==1)
			begin
				state <= IDLE;
			end
			else
			begin
				state <= WRITE_LSB;
			end
		end
		WRITE_LSB:
		begin
			CEB1 	<= 0;
			CMD1 	<= 0;
			ADD1 	<= ADD1+1;
			DIN1 	<= cnt[7:0];
			state 	<= WRITE_MSB;
		end
		WRITE_MSB:
		begin
			ADD1 	<= ADD1+1;
			DIN1 	<= cnt[15:8];
			cnt 	<= cnt+1;
			CEB1 	<= 0;
			CMD1 	<= 0;
			if (cnt<write_num)
			begin
				state <= WRITE_LSB;
			end
			else
			begin
				state <= WRITE_DONE_ST;
			end
		end
		WRITE_DONE_ST:
		begin
			WRITE_DONE 	<= 1;
			state 		<= SET_READ_LSB;
			CEB1 		<= 1;
			CMD1 		<= 1;
			cnt 		<= 1;
			
		end
		SET_READ_LSB:
		begin
			CEB2 		<= 0;
			CMD2 		<= 1;
			ADD2 		<= ADD2+1;
			state 		<= READ_LSB;
			
		end
		READ_LSB:
		begin
			LSB_DATA	<= Q2;
			state 		<= SET_READ_MSB;
		end
		SET_READ_MSB:
		begin
			CEB2 		<= 0;
			CMD2 		<= 1;
			ADD2 		<= ADD2+1;
			state 		<= READ_MSB;
			
		end
		READ_MSB:
		begin
			MSB_DATA	<= Q2;
			if (rcnt<write_num)
			begin
				state 	<= SET_READ_LSB;
				rcnt 	<= rcnt+1;
				CEB2 	<= 0;
				CMD2 	<= 1;
			end
			else
			begin		
				READ_DONE 	<= 1;
				state <= IDLE;
				CEB2 	<= 1;
				CMD2 	<= 1;
				rcnt 	<= 1;
			end
			
		end
		endcase
	
	end

end
always @(posedge CLK or posedge RST)
begin
	if(RST) begin
		clkd 	<= 0;
		div_cnt <= 0;
		dac_sample <=0;
	end
	else begin
		case (div_cnt)
		0: begin 
		clkd 	<= 0;
		div_cnt	<= 1;
		end
		1: begin 
		clkd 	<= 1;
		div_cnt	<= 2;
		end
		2: begin 
		clkd 	<= 1;
		div_cnt	<= 3;
		end
		3: begin 
		clkd 	<= 0;
		div_cnt	<= 0;
		end
		default: begin
		clkd 	<= 0;
		div_cnt <= 0;	
		end
		endcase
	end
end


always @(posedge clkd or posedge RST)
begin
	if(RST) 
	begin
		DOUT <= 0;
	end
	else 
	begin
		if (WRITE_DONE==1)
		begin
			DOUT <= {MSB_DATA,LSB_DATA};
		end
			
	end
end
endmodule

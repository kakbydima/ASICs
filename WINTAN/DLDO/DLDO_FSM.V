// ver4 rev 2.3
// Issue1 : counter_linear was not being updated if it goes out of DZ during linear mode (and not finishing SAR with all test cnt == 0)
// Solution : Added "counter_linear	<=0;" too all not "linear" state if statements
// ver4 rev2.5
// Issue: redundancy of a mask register
// Solution : assign sol[cnt-1] = 1/0 instead + correct initial sol value from all ones to 01111111111111

//ver5_rev0
//Implementation of one step for minimum current load
//threshold implementation

//ver5_rev0p1
//Issue1: linear_counter doesn't reset when VREG  crosses VREF
//Solution: insert linear_counter <= 0 in VOM: 1 --> 0 or 0 --> 1

//ver5_rev0p2
//Threshold for linear modes should be stored in registers
		
//ver5_rev0p3
//Issue: linear step is limited only by 8 
//Solution: Set input value to put max linear step(value is limited by (2^10-1) ), so linear step would be limited by 1024
//ver5_rev0p4
//Issue: linear step is limited only by 8 
//Solution: Set input value to put max linear step(value is limited by (2^8-1) ), so linear step would be limited by 256

// V5_rev1
// REMOVED LINTH AND MAXSTEPSIZE AS REGISTERS  		

// Created by ihdl
module DLDOSM_v5_rev1(
CLKD,
RST, 
VOH,
VOL,
VOM,
inDZ,
LINTH,
MAXSTEPSIZE,

osh,
osl,
dzcnt,
clkdone,
cnt,
sol,
vom_old_high,
vom_old_low,
SROUT,
sardone,
sarb,
SRL,
VLK,
blsel,
linear_counter,
linear_step,
clk
//VDD,
//VSS
);

input CLKD, RST;
input VOH;
input VOL;
input VOM;
input inDZ;  
input [13:0] LINTH;
input [7:0] MAXSTEPSIZE;

output reg osh;
output reg osl;
output reg [2:0] dzcnt;
output reg clkdone;


output reg [3:0] cnt;
output reg [13:0] sol;
output reg vom_old_high;
output reg vom_old_low;
output [13:0] SROUT;
output reg sardone;
output reg sarb;
output reg [2:0] linear_counter;
//output reg [3:0] linear_step;
output reg [7:0] linear_step;
output   	SRL;
output   	VLK;
output reg blsel;
output clk;
wire [13:0] linth1;
wire [7:0] maxstepsize1;
wire lin;  
//wire inDZ;    
wire clk; 
wire OSLSET;   
//inout VDD;
//inout VSS;
//
assign linth1 = LINTH;
assign maxstepsize1 = MAXSTEPSIZE;



//assign inDZ = ~VOH&VOL; 
assign clk = blsel ? CLKD : inDZ;
//Binary linear mode

assign lin = (clkdone | sardone);

always @(posedge lin or negedge inDZ)
begin
if (~inDZ)
begin
	blsel <=0;
end
else
begin
	blsel <=1;
end
end


//SET all pins to zeros of ones if it goes out of DZ
assign SROUT [0] = ((sol [0] & VOL)| VOH)|RST;
assign SROUT [1] = ((sol [1] & VOL)| VOH)|RST;
assign SROUT [2] = ((sol [2] & VOL)| VOH)|RST;
assign SROUT [3] = ((sol [3] & VOL)| VOH)|RST;
assign SROUT [4] = ((sol [4] & VOL)| VOH)|RST;
assign SROUT [5] = ((sol [5] & VOL)| VOH)|RST;
assign SROUT [6] = ((sol [6] & VOL)| VOH)|RST;
assign SROUT [7] = ((sol [7] & VOL)| VOH)|RST;
assign SROUT [8] = ((sol [8] & VOL)| VOH)|RST;
assign SROUT [9] = ((sol [9] & VOL)| VOH)|RST;
assign SROUT [10] = ((sol [10] & VOL)| VOH)|RST;
assign SROUT [11] = ((sol [11] & VOL)| VOH)|RST;
assign SROUT [12] = ((sol [12] & VOL)| VOH)|RST;
assign SROUT [13] = ((sol [13] & VOL)| VOH)|RST;



 



//SETS osl to High when RST is high
assign OSLSET = ~VOL|RST; 

//One shot logic osl, when VOL low - osl goes high, to remember that it was belowDZ. And it is being reset to LOW as soon as VOH is HIGH
always @ (posedge VOH or negedge VOL)
begin 
	if (VOH) 
	begin
		osl <= 0;
	end 
	else
	begin
		osl <= 1;
	end
end

//One shot logic osh, when VOH HIGH - osh goes high, to remember that it was belowDZ. And it is being reset to LOW as soon as VOL is LOW or RST is HIGH
always @ (posedge OSLSET or posedge VOH)
begin 
	if (OSLSET)
	begin
		osh <= 0;
	end 
	else
	begin
		osh <= 1;
	end
end

// COUNTER FOR CLKD TO GO TO LINEAR MODE or RST counter as soon as inDZ is LOW
always @ (posedge CLKD or negedge inDZ or posedge RST)
begin
	if (RST==1) 
	begin
		dzcnt <= 0;
		clkdone <= 0;
	end
	else
	begin
		//vom_old <= VOM; 
		if (inDZ==0)
		begin
			dzcnt 		<= 0;
			clkdone  	<= 0;
		end 
		else
		begin
			if (dzcnt < 3)
			begin
				dzcnt <= dzcnt + 1;
			end
			else
			begin
				clkdone  	<= 1;
				dzcnt 		<= 3;
			end
		end
	end
end



//SAR LOGIC + linear
always @ (posedge clk or posedge RST) 
begin
if (RST==1) 
begin
	cnt 	<= 13;
	sol	<= 14'b11111111111111;
	sarb 	<= 1;
	linear_counter	<= 0;
	linear_step	<= 1;
	sardone	<= 0;
	vom_old_high <= 0;
	vom_old_low  <= 0;
//	linth1 <= LINTH;
//	maxstepsize1 <= MAXSTEPSIZE;
		
end 
else
begin
	if (osh&~blsel) //When it came inDZ from aboveDZ
	begin
		linear_counter	<=0;
		linear_step	<=1;
		if (sarb == 1) //Resets binary search if it was in linear
		begin
			sarb <= 0;
			cnt <=13;
			//sol	<= 14'b11111111111111;
			sol	<= 14'b01111111111111; // DIMA FARTED HERE
			sardone	<= 0;
		end
		else if(cnt == 0) //Move to linear
		begin
			sardone	<= 1;	
			sarb <= 1; 
			sol[cnt] <= 1; // DIMA FARTED HERE
		end
		else
		begin
			sardone	<= 0;
			cnt	<= cnt-1;
			sol[cnt] <= 1;
			sol[cnt-1] <= 0;			
		end
		vom_old_high <= 0;
		vom_old_low  <= 0;
	end
	else if (osl&~blsel) //When it came inDZ from belowDZ
	begin
		linear_counter	<=0;
		linear_step	<=1;
		if (sarb == 1) //Resets binary search if it was in linear
		begin			
			sarb <= 0;
			cnt <=13;
			//sol	<= 14'b11111111111111;
			sol	<= 14'b01111111111111; // DIMA FARTED HERE
			sardone	<= 0;
		end
		else if (cnt == 0)
		begin
			sardone	<= 1;
			sarb <= 1;	
			sol[cnt] <= 0; // DIMA FARTED HERE
		end
		else
		begin	
			sardone	<= 0;
			cnt	<= cnt-1;	
			sol[cnt] <= 0;
			sol[cnt-1] <= 0;
		end
		vom_old_high <= 0;
		vom_old_low  <= 0;
	end
	else //Should go here only when blsel is high at posedge of CLKD
	begin
		sarb <= 1'b1; // To reset cnt and sol if it was 1
		if(VOM==1 && vom_old_high==1)
		begin
			if (sol<linth1) //if smaller or equal than linear threshold --> go to incremental step size
			begin
				if(linear_counter<2)
				begin
					linear_counter	<= linear_counter+1;
				end			
				else
				begin
					if(linear_step<maxstepsize1)
					begin
						linear_step	<= linear_step<<1; //put it back to 1
					end
					else
					begin
						linear_step	<= maxstepsize1;
					end
					linear_counter  <= 0;
				end			
				if (sol<(14'b11111111111111-linear_step)) 
				begin
					sol	<= (sol+linear_step);
				end
				else
				begin
					sol <= 14'b11111111111111; // skip if not true // DIMA FARTED HERE
				end
			end
			else
			begin
				if (sol<14'b11111111111111)
				begin
					sol	<= (sol+1);
				end
				else
				begin
					sol <= 14'b11111111111111;
				end			
			end
			vom_old_high	<= 1;
			vom_old_low	<= 0;
		end
		else if(VOM==0 && vom_old_low==1)
		begin
			if (sol< linth1) //if smaller or equal than linear threshold --> go to incremental step size
			begin
				// Modify linear step
				if(linear_counter<2)
				begin
					linear_counter	<= linear_counter+1;
				end			
				else
				begin
					if(linear_step<maxstepsize1)
					begin
						linear_step	<= linear_step<<1;
					end
					else
					begin
						linear_step	<= maxstepsize1;
					end
					linear_counter  <= 0;
				end
				// Apply linear step	
				if(sol>(14'b00000000000000+linear_step)) 
				begin
					sol	<= (sol-linear_step);
				end
				else
				begin
					sol <= 14'b00000000000000;// skip if not true
				end
			end
			else
			begin
				if (sol>14'b00000000000000)
				begin
					sol	<= (sol-1);
				end
				else
				begin
					sol <= 14'b00000000000000;
				end	
			end
			vom_old_low	<= 1;
			vom_old_high	<= 0;
		end
		else // VOM: 1 --> 0 or 0 --> 1
		begin
			linear_counter <= 0;  // 
			if(linear_step>1)
			begin			
				linear_step	<= linear_step>>1;
			end			
			else
			begin
				linear_step	<=1;
			end			
			if(VOM==1)
			begin
				vom_old_high	<= 1;
				vom_old_low	<= 0;
			end
			else
			begin
				vom_old_high	<= 0;
				vom_old_low	<= 1;
			end
		end
	end
end
end

assign SRL = VOM || !blsel;
assign VLK = (SROUT == 14'b11111111111111) ? VOM : 0;

endmodule

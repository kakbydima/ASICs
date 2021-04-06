//Verilog HDL for "intanW_dima_rf", "SRAM_behav_v1_rev01" "functional"

// this is git test
module SRAM_behav_v2_rev02(
    CLK,
    RST,
    CMD1,
    CEB1,
    ADD1,
    DIN1,
    Q1,
    CMD2,
    CEB2,
    ADD2,
    DIN2,
    Q2,
	mem0add_check
);
input           CLK;
input           RST;
input           CEB1; 
input           CMD1;    //0 - write, 1 - read
input[9:0]      ADD1;
input[7:0]      DIN1;
output  [7:0]     Q1;   //data out
 reg [7:0]     q1;   //data out

input           CEB2; 
input           CMD2;    //0 - write, 1 - read
input[9:0]      ADD2;
input[7:0]      DIN2;
output  [7:0]     Q2;   //data out
 reg [7:0]     q2;   //data out

//reg[7:0]     Q;
output [7:0] mem0add_check;
integer out, i;

// Declare memory 64x8 bits = 512 bits or 64 bytes 
// Declare memory 1024x8 bits
 reg [7:0] memory_ram_d [1023:0];

assign mem0add_check = memory_ram_d[20];

always @(posedge CLK or posedge RST)
begin
    if (RST)
    begin
	q1<=0;
	q2<=0;
        for (i=0;i<1024; i=i+1)
            memory_ram_d[i] <= 250;
    end
    else
    begin
	if (CEB1==0)
	begin
		if (!CMD1)  //write
		begin
			memory_ram_d[ADD1] <= DIN1;
		end
		else //read
		begin
			q1 <= memory_ram_d[ADD1];
		end  
	end
	
	if (CEB2==0)
	begin
		if (!CMD2)  //write
		begin
			memory_ram_d[ADD2] <= DIN2;
		end
		else //read
		begin
			q2 <= memory_ram_d[ADD2];
		end    
	end
    end
end

assign Q1 = q1;
assign Q2 = q2;

/*always @(negedge CLK or posedge RST)
begin
	if (RST)
	begin
		Q1 <= 0;
		Q2 <= 0;
	end
	else
	begin
		Q1 <= q1;
		Q2 <= q2;
	end
 end
*/
endmodule

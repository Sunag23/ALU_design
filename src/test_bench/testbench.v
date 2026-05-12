`timescale 1ns/1ps

module tb_alu;

parameter N = 8;
integer file_id;
reg CLK;
reg RST;
reg [1:0] INP_VALID;
reg MODE;
reg [3:0] CMD;
reg CE;
reg [N-1:0] OPA, OPB;
reg CIN;

wire ERR,RERR;
wire [(2*N)-1:0] RES,RRES; 
wire OFLOW,ROFLOW;
wire COUT,RCOUT;
wire G,RG, RL,L, RE,E;


ALU_design1 #(.WIDTH(N)) dut (
        .CLK(CLK), .RST(RST), .CE(CE), .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .INP_VALID(INP_VALID), .MODE(MODE), .CMD(CMD),
        .RES(RES), .ERR(ERR), .COUT(COUT), .OFLOW(OFLOW), .G(G), .L(L), .E(E)
    );

alu #(.N(N)) uut (
        .clk(CLK), .rst(RST), .CE(CE), .OPA(OPA), .OPB(OPB), .cin(CIN),
        .input_valid(INP_VALID), .mode(MODE), .cmd(CMD),
        .res(RRES), .err(RERR), .cout(RCOUT), .OFLOW(ROFLOW), .G(RG), .L(RL), .E(RE)
    );

task DRIVE_INPUT;
    input t_rst, t_ce;
    input [N-1:0] t_opa, t_opb;
    input t_mode;
    input [3:0] t_cmd;
    input t_cin;
    input [1:0] t_valid;
    begin
        @(negedge CLK);
        RST = t_rst; CE = t_ce; OPA = t_opa; OPB = t_opb;
        MODE = t_mode; CMD = t_cmd; CIN = t_cin; INP_VALID = t_valid;
        #1;
    end
endtask
always #5 CLK = ~CLK;

task nop;
begin
@(posedge CLK);
end
endtask

task SCORECARD;
	begin
	#1;
	if(RES!=RRES || ERR!=RERR || RCOUT!=COUT || OFLOW!=ROFLOW || G!=RG || L!=RL || E!=RE)begin
		$fdisplay(file_id,"TEST FAILED");
		$fdisplay(file_id,"INP_VALID=%b MODE=%0d CMD=%0d OPA=%0d OPB=%0d CIN=%0d RESET=%0d CE=%0d",INP_VALID,MODE,CMD,OPA,OPB,CIN,RST,CE);
		$fdisplay(file_id,"Actual Result RES=%0d ERR=%0d COUT=%0d OFLOW=%0d G=%0d L=%0d E=%0d",RES,ERR,COUT,OFLOW,G,L,E);
		$fdisplay(file_id,"Expected Result RES=%0d ERR=%0d COUT=%0d OFLOW=%0d G=%0d L=%0d E=%0d",RRES,RERR,RCOUT,ROFLOW,RG,RL,RE);
		$fdisplay(file_id,"**************************************************\n");

	end
	else begin
		$fdisplay(file_id,"TEST PASSED");
		$fdisplay(file_id,"INP_VALID=%b MODE=%0d CMD=%0d OPA=%0d OPB=%0d CIN=%0d RESET=%0d CE=%0d",INP_VALID,MODE,CMD,OPA,OPB,CIN,RST,CE);
		$fdisplay(file_id,"Result RES=%0d ERR=%0d COUT=%0d OFLOW=%0d G=%0d L=%0d E=%0d",RES,ERR,COUT,OFLOW,G,L,E);
		$fdisplay(file_id,"**************************************************\n");
	end
	end
endtask

initial begin
file_id=$fopen("report.txt","w");
if(file_id==0)$display("empty");
CLK = 0;
RST = 1; CE = 0; MODE = 0; CMD = 0; 
OPA = 0; OPB = 0; CIN = 0; INP_VALID = 0;

#15; 

$display("--- STARTING TESTS ---");
//ADDITION
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd0,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd0,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd10);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd2,1'b1,4'd0,1'd0,2'd01);
nop();
nop();
SCORECARD();
//SUBTRACTION
DRIVE_INPUT(1'b0,1'b1,8'd3,8'd2,1'b1,4'd1,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd1,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd1,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd1,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd1,1'd0,2'd01);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd1,1'd0,2'd10);
nop();
nop();
SCORECARD();
//SUBTRACTION CIN
DRIVE_INPUT(1'b0,1'b1,8'd3,8'd2,1'b1,4'd3,1'd1,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd3,1'd1,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd3,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd3,1'd0,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd3,1'd0,2'd01);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd3,1'd0,2'd10);
nop();
nop();
SCORECARD();
//ADD CIN
DRIVE_INPUT(1'b0,1'b1,8'd3,8'd2,1'b1,4'd2,1'd1,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd0,8'd0,1'b1,4'd2,1'd1,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd255,8'd255,1'b1,4'd2,1'd1,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd2,8'd8,1'b1,4'd2,1'd1,2'd11);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd253,8'd1,1'b1,4'd2,1'd1,2'd10);
nop();
nop();
SCORECARD();
DRIVE_INPUT(1'b0,1'b1,8'd253,8'd1,1'b1,4'd2,1'd1,2'd01);
nop();
nop();
SCORECARD();

//INC_A
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd0, 1'b1, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd255, 1'b1, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd4, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd4, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
//DEC_A
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd0, 1'b1, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd255, 1'b1, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd5, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd5, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
//INC_B
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd15, 1'b1, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd255, 1'b1, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd10, 1'b1, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd10, 1'b1, 4'd6, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd10, 1'b1, 4'd6, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//DEC_B
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd15, 1'b1, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd255, 1'b1, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd10, 1'b1, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd10, 1'b1, 4'd7, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd10, 1'b1, 4'd7, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//CMP
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd15, 1'b1, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b1, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b1, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd15, 1'b1, 4'd8, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd15, 1'b1, 4'd8, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//INC MULTIPLICATION
DRIVE_INPUT(1'b0, 1'b1, 8'd5, 8'd4, 1'b1, 4'd9, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd0, 1'b1, 4'd9, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b1, 4'd9, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd2, 1'b1, 4'd9, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd5, 8'd4, 1'b1, 4'd9, 1'b0, 2'b01);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd5, 8'd4, 1'b1, 4'd9, 1'b0, 2'b10);
nop(); nop(); nop(); SCORECARD();
//SHIFT OPA MULTIPLICATION
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd4, 1'b1, 4'd10, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd10, 1'b1, 4'd10, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b1, 4'd10, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd2, 1'b1, 4'd10, 1'b0, 2'b11);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd4, 1'b1, 4'd10, 1'b0, 2'b01);
nop(); nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd4, 1'b1, 4'd10, 1'b0, 2'b10);
nop(); nop(); nop(); SCORECARD();
//SIGNED ADDITION
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b1, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b1, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd240, 1'b1, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b1, 4'd11, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b1, 4'd11, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//SIGNED SUBTRACTION
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd240, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b1, 4'd12, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b1, 4'd12, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//AND
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd0, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b11111111, 1'b0, 4'd0, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00000000, 8'b00000000, 1'b0, 4'd0, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b00001111, 1'b0, 4'd0, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd0, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd0, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//NAND
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd1, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00000000, 8'b00000000, 1'b0, 4'd1, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b11111111, 1'b0, 4'd1, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11110000, 8'b00001111, 1'b0, 4'd1, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd1, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd1, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
//OR
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd2, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11110000, 8'b00000000, 1'b0, 4'd2, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b11111111, 1'b0, 4'd2, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11110000, 8'b00001111, 1'b0, 4'd2, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd2, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd2, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//NOR
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd3, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00000000, 8'b00000000, 1'b0, 4'd3, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b11111111, 1'b0, 4'd3, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11110000, 8'b00001111, 1'b0, 4'd3, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd3, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd3, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//XOR
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00000000, 8'b00000000, 1'b0, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b11111111, 1'b0, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11000000, 8'b00000011, 1'b0, 4'd4, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd4, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd4, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//XNOR
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00000000, 8'b00000000, 1'b0, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'b11111111, 1'b0, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11110000, 8'b00001111, 1'b0, 4'd5, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd5, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'b01010101, 1'b0, 4'd5, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//NOT_A
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd0, 1'b0, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00000000, 8'd0, 1'b0, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11111111, 8'd0, 1'b0, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11001100, 8'd255, 1'b0, 4'd6, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd0, 1'b0, 4'd6, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd0, 1'b0, 4'd6, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
// NOT B
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'b01010101, 1'b0, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'b00000000, 1'b0, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'b11111111, 1'b0, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'b00110011, 1'b0, 4'd7, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'b01010101, 1'b0, 4'd7, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'b01010101, 1'b0, 4'd7, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//OPA>>1
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd20, 1'b0, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd15, 1'b0, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd0, 1'b0, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd8, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd8, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//OPA<<1
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd9, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd20, 1'b0, 4'd9, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd15, 1'b0, 4'd9, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd255, 1'b0, 4'd9, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd9, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd9, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//OPB>>1
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd10, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd20, 1'b0, 4'd10, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd15, 8'd15, 1'b0, 4'd10, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b0, 4'd10, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd10, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd20, 8'd10, 1'b0, 4'd10, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//OPB<<1
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b0, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd0, 8'd0, 1'b0, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd255, 1'b0, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd170, 8'd85, 1'b0, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b0, 4'd11, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd10, 8'd5, 1'b0, 4'd11, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//ROTATE LEFT
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd1, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10000000, 8'd1, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd0, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd7, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b11110000, 8'd4, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd8, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'b00010001, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'b10000001, 1'b0, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd2, 1'b0, 4'd12, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd2, 1'b0, 4'd12, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
//ROTATE RIGHT
DRIVE_INPUT(1'b0, 1'b1, 8'b00000001, 8'd1, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd1, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd0, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd7, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b00001111, 8'd4, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10101010, 8'd8, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'b00010001, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'b11110001, 1'b0, 4'd13, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd2, 1'b0, 4'd13, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd2, 1'b0, 4'd13, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
//CE
DRIVE_INPUT(1'b0, 1'b0, 8'b10110011, 8'd2, 1'b0, 4'd13, 1'b0, 2'b10);
SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'b10110011, 8'd2, 1'b0, 4'd13, 1'b0, 2'b10);
nop();nop();SCORECARD();
//RST
DRIVE_INPUT(1'b1, 1'b1, 8'b10110011, 8'd2, 1'b0, 4'd13, 1'b0, 2'b10);
SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd128, 1'b1, 4'd11, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd255, 8'd127, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd127, 8'd128, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b1, 4'd12, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd9, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd10, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd9, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd10, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd10, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd8, 1'b0, 2'b01);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd8, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd10, 1'b0, 2'b11);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd10, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
//default
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b0, 4'd15, 1'b0, 2'b10);
nop(); nop(); SCORECARD();
DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b1, 4'd15, 1'b0, 2'b10);
nop(); nop(); SCORECARD();

DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd127, 1'b1, 4'd0, 1'b0, 2'b10);
nop(); nop(); SCORECARD();

DRIVE_INPUT(1'b0, 1'b1, 8'd128, 8'd128, 1'b1, 4'd10, 1'b0, 2'b10);
nop(); nop(); nop();SCORECARD();
$fclose(file_id);
#50 $finish;
end

endmodule

`timescale 1ns / 1ps
module alu#(parameter N=8,parameter W=4)
(
input wire clk,
input wire rst,
input wire [1:0]input_valid,
input wire mode,
input wire [W-1:0]cmd,
input wire CE,
input wire [N-1:0]OPA,
input wire [N-1:0]OPB,
input wire cin,
output reg err,
output reg [2*N-1:0]res,
output reg OFLOW,
output reg cout,
output reg G,
output reg L,
output reg E
 );

 reg [1:0] count;
 always @(posedge clk or posedge rst)
 begin
 if(rst)
    count<=2'b00;
 else if(cmd==4'd9)
    count<=count+1;
 else
     count<=0;
 end
 
 always @(posedge clk or posedge rst)
 begin
 if(rst)
 begin
 res<={2*N{1'bz}};
 err<=1'b0;
 OFLOW<=1'b0;
 G<=1'b0;
 L<=1'b0;
 E<=1'b0;
 cout<=1'b0;
 end
 else if(!CE)
 begin
 res<=res;
 err<=err;
 OFLOW<=OFLOW;
 G<=G;
 L<=L;
 E<=E;
 cout<=cout;
 end
 else if (mode)
 begin
 case(cmd)
 
 4'd0:begin
 if(input_valid==2'b11)
 begin
 res<=OPA+OPB;
 cout<=res[9];
 OFLOW<=1'b0;
 {err,G,E,L}<=4'b0000;
 end
 else
 begin
 err<=1'b1;
 {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
 end
 end
 
 4'd1:begin
 if(input_valid==2'b11)
 begin
 res<=OPA-OPB;
 cout<=(OPA>=OPB);
 OFLOW<=!(OPA>=OPB);
 {err,G,E,L}<=4'b0000;
 end
 else
 begin
 err<=1'b1;
 {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
 end
 end
 
 4'd2:begin
     if(input_valid==2'b11)
      begin
        res<=OPA+OPB+cin;
        cout<=(OPA+OPB+cin)>>N;
        OFLOW<=1'b0;
        {err,G,E,L}<=4'b0000;
     end
 else
    begin
        err<=1'b1;
       {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end 
 
 4'd3:begin
    if(input_valid==2'b11)
     begin
        res<=OPA-OPB-cin;
        cout<=({1'b0,OPA}>={1'b0,OPB}+cin);
        OFLOW<=({1'b0, OPA} < ({1'b0, OPB} + cin));
        {err,G,E,L}<=4'b0000;
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end 
 
4'd4:
begin
if(input_valid[0])
    begin
        res<=OPA+1;
        cout<=(OPA==0);
        OFLOW<=1'b0;
        {err,G,E,L}<=4'b0000;
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end
 
 
 4'd5:
begin
if(input_valid[0])
    begin
        res<=OPA-1;
        cout<=(OPA==0);
        OFLOW<=1'b0;
        {err,G,E,L}<=4'b0000;
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end
 
  4'd6:
begin
if(input_valid[1])
    begin
        res<=OPB+1;
        cout<=(OPB==0);
        OFLOW<=1'b0;
        {err,G,E,L}<=4'b0000;
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end
 
 
 4'd7:
begin
if(input_valid[1])
    begin
        res<=OPB-1;
        cout<=(OPB==0);
        OFLOW<=1'b0;
        
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end
 
 4'd8:
begin
if(input_valid==2'b11)
    begin
        {err,cout,OFLOW}<=4'b0000;  
        res<={N{2'b00}};
        {G,E,L}<={(OPA>OPB),(OPA==OPB),(OPA<OPB)};
         
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
    end
 end
 
 4'd9:
 begin
 if(input_valid==2'b11)
    begin
    if(count==2'b10)
        res<=(OPA+1)*(OPB+1);
    else
        res<=res;
    end 
 else
 begin
   err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
        end
    end
    
 4'd10:begin
 if(input_valid==2'b11)
    begin
    if(count==2'b10)
    begin
    res<=(OPA<<1)*OPB;
    {OFLOW,cout,G,L,E}<=5'b00000;
    end
    end
 else
    begin
        err<=1'b1;
        {res,OFLOW,cout,G,L,E}<={res,OFLOW,cout,G,L,E};
      end
      end
 
 4'd11:begin
  if(input_valid==2'b11)
  begin
   if(count==2'b10)
   begin
  res<=$signed(OPA)+$signed(OPB);
  OFLOW<= ((OPA[N-1] == OPB[N-1]) && (res[N-1] != res[N-1]));
  {G,L,E}<={($signed(OPA)>$signed(OPB)),($signed(OPA)<$signed(OPB)),($signed(OPA)==$signed(OPB))};
  cout<=0;
  end
  else
    err<=1'b1;
  end
  end
  
 4'd12:begin
 if(input_valid==2'b11)
 begin
 if(count==2'b10)
   begin
  res<=$signed(OPA)-$signed(OPB);
  OFLOW<= (OPA[N-1] != OPB[N-1]) && (res[N-1] != res[N-1]);
  {G,L,E}<={($signed(OPA)>$signed(OPB)),($signed(OPA)<$signed(OPB)),($signed(OPA)==$signed(OPB))};
  cout<=0;
  end
  else
    err<=1'b1;
  end
  end
  endcase
 end
 
 else
  begin
   {err,OFLOW,cout,G,E,L} <= 6'b0;
    case(cmd)
    4'd0:begin
     if(input_valid==2'b11)
        res<=OPA&OPB;
     end
    4'd1:begin
     if(input_valid==2'b11)
        res<=~(OPA&OPB);
     end
    4'd2:begin
    if(input_valid==2'b11)
        res<=OPA|OPB;
    end
    4'd3:begin
    if(input_valid==2'b11)
        res<=~(OPA|OPB);
    end 
    4'd4:begin
    if(input_valid==2'b11)
        res<=OPA^OPB;
    end
    4'd5:begin
    if(input_valid==2'b11)
        res<=~(OPA^OPB);
    end 
    4'd6:begin
    if(input_valid[0])
        res<=~(OPA);
    end
    4'd7:begin
    if(input_valid[1])
        res<=~(OPB);
    end
    4'd8:begin
    if(input_valid[0])
    res<=OPA>>1;
    end
    4'd9:begin
    if(input_valid[0])
    res<=OPA<<1;
    end
    4'd10:begin
    if(input_valid[1])
    res<=OPB>>1;
    end
    4'd11:begin
    if(input_valid[1])
    res<=OPB<<1;
    end
    4'd12:begin
    if(input_valid==2'b11)
    begin
    casex(OPB)
    8'b0000x000:res=OPA;
    8'b0000x001:res={OPA[N-1:1],OPA[0]};
    8'b0000x010:res={OPA[N-1:2],OPA[1:0]};
    8'b0000x011:res={OPA[N-1:3],OPA[2:0]};
    8'b0000x100:res={OPA[N-1:4],OPA[3:0]};
    8'b0000x101:res={OPA[N-1:5],OPA[4:0]};
    8'b0000x110:res={OPA[N-1:6],OPA[5:0]};
    8'b0000x111:res={OPA[N-1:1],OPA[0]};
    default:err=1'b1;
    endcase
    end
    else
    err<=1'b1;
    end
    4'd13:begin
    if(input_valid==2'b11)
    begin
    casex(OPB)
    8'b0000x000:res=OPA;
    8'b0000x001:res={OPA[0],OPA[N-1:1]};
    8'b0000x010:res={OPA[1:0],OPA[N-1:2]};
    8'b0000x011:res={OPA[2:0],OPA[N-1:3]};
    8'b0000x100:res={OPA[3:0],OPA[N-1:4]};
    8'b0000x101:res={OPA[4:0],OPA[N-1:5]};
    8'b0000x110:res={OPA[5:0],OPA[N-1:6]};
    8'b0000x111:res={OPA[0],OPA[N-1:1]};
    default:err=1'b1; 
   endcase
    end
    else
    err<=1'b1;
    end
    endcase
 end
 end
endmodule


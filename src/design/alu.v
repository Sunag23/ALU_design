`timescale 1ns / 1ps

module alu #(parameter N=8, parameter W=4)
(
    input wire clk,
    input wire rst,
    input wire [1:0] input_valid,
    input wire mode,
    input wire [W-1:0] cmd,
    input wire CE,
    input wire [N-1:0] OPA,
    input wire [N-1:0] OPB,
    input wire cin,

    output reg err,
    output reg [2*N-1:0] res,
    output reg OFLOW,
    output reg cout,
    output reg G,
    output reg L,
    output reg E
);

reg [1:0] count;

wire [N-1:0] diff = $signed(OPA) - $signed(OPB);
wire [N-1:0] sum  = $signed(OPA) + $signed(OPB);

always @(posedge clk or posedge rst)
begin
    if(rst)
        count <= 0;

    else if(CE)
    begin
      if(mode&&(cmd==4'd9 || cmd==4'd10))
        begin
            if(count < 3)
                count <= count+1;
            else
                count <= 0;
        end

        else
        begin
            if(count < 1)
                count <= count + 1;
            else
                count <= 0;
        end
    end
end

always @(posedge clk or posedge rst)
begin

if(rst)
begin
    res    <= 0;
    err    <= 0;
    OFLOW <= 0;
    cout   <= 0;
    G      <= 0;
    L      <= 0;
    E      <= 0;
end

else if(!CE)
begin
    res    <= res;
    err    <= err;
    OFLOW <= OFLOW;
    cout   <= cout;
    G      <= G;
    L      <= L;
    E      <= E;
end

else if(mode)
begin

case(cmd)

4'd0:
begin
    if(input_valid==2'b11)
    begin
        res <= OPA + OPB;
        cout <= ({1'b0,OPA} + {1'b0,OPB}) >> N;
        OFLOW <= 0;
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end

4'd1:
begin
    if(input_valid==2'b11)
    begin
        res <= OPA - OPB;
        OFLOW <= !(OPA >= OPB);
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end

4'd2:
begin
    if(input_valid==2'b11)
    begin
        res <= OPA + OPB + cin;
        cout <= ({1'b0,OPA} + {1'b0,OPB} + cin) >> N;
        OFLOW <= 0;
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end

4'd3:
begin
    if(input_valid==2'b11)
    begin
        res <= OPA - OPB - cin;
        OFLOW <= ({1'b0,OPA} < ({1'b0,OPB}+cin));
        {err,G,E,L,cout} <= 0;
    end
    else
        err <= 1;
end

4'd4:
begin
    if(input_valid[0])
    begin
        res[N-1:0] <= OPA + 1;
        OFLOW <= 0;
        {err,G,E,L,cout} <= 0;
    end
    else
        err <= 1;
end

4'd5:
begin
    if(input_valid[0])
    begin
        res[N-1:0] <=OPA - 1;
        OFLOW <= 0;
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end

4'd6:
begin
    if(input_valid[1])
    begin
        res[N-1:0] <=OPB + 1;
        OFLOW <= 0;
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end

4'd7:
begin
    if(input_valid[1])
    begin
        res[N-1:0] <=OPB - 1;
        OFLOW <= 0;
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end

4'd8:
begin
    if(input_valid==2'b11)
    begin
        res <= 0;
        {G,E,L} <= {
            (OPA > OPB),
            (OPA == OPB),
            (OPA < OPB)
        };
        {err,cout,OFLOW} <= 0;
    end
    else
        err <= 1;
end

4'd9:
begin
    if(input_valid==2'b11)
    begin
	err<=0;
        if(count==2'b10)
            res <= ({1'b0, OPA} + 1) * ({1'b0, OPB} + 1);
	    {OFLOW,cout,G,L,E} <= 0;
    end
    else
        err <= 1;
end

4'd10:
begin
    if(input_valid==2'b11)
    begin
	err<=0;
        if(count==2'b10)
        begin
            res <=( ({8'b0, OPA} * {8'b0, OPB}) << 1 );
            {OFLOW,cout,G,L,E} <= 0;
        end
    end
    else
        err <= 1;
end

4'd11:
begin
    if(input_valid==2'b11)
    begin
	err<=0;
	if(count == 2'b01)
	  begin
            res <= sum; // Uses all bits of sum

            // Reference sum[N-1] and OPA[N-1] to detect signed overflow
            OFLOW <= ((OPA[N-1] == OPB[N-1]) &&(sum[N-1] != OPA[N-1]));

            {G,L,E} <= {
                ($signed(OPA) > $signed(OPB)),
                ($signed(OPA) < $signed(OPB)),
                ($signed(OPA) == $signed(OPB))
            };

            cout <= 0;
    end
end
    else
	begin
        err <= 1;
	end
end

4'd12:
begin
    if(input_valid==2'b11)
    begin
	err<=0;
	if(count == 2'b01)
	  begin
            res <= diff; // Uses all bits of diff

            OFLOW <= ((OPA[N-1] != OPB[N-1]) &&(diff[N-1] != OPA[N-1]));

            {G,L,E} <= {
                ($signed(OPA) > $signed(OPB)),
                ($signed(OPA) < $signed(OPB)),
                ($signed(OPA) == $signed(OPB))
            };

            cout <= 0;
        end
end
    else
        err <= 1;
end
default:err=1'b1;

endcase

end

else
begin

{err,OFLOW,cout,G,E,L} <= 0;

case(cmd)
4'd0:
if(input_valid==2'b11)
    res <={{N{1'b0}}, OPA & OPB};
else
        err <= 1;

4'd1:
if(input_valid==2'b11)
    res <={{N{1'b0}}, ~(OPA & OPB)};
else
	err<=1;

4'd2:
if(input_valid==2'b11)
    res <={{N{1'b0}},OPA | OPB};
else
	err<=1;

4'd3:
if(input_valid==2'b11)
    res <={{N{1'b0}}, ~(OPA | OPB)};
else
	err<=1;

4'd4:
if(input_valid==2'b11)
    res <={{N{1'b0}}, OPA ^ OPB};
else
	err<=1;

4'd5:
if(input_valid==2'b11)
    res <={{N{1'b0}}, ~(OPA ^ OPB)};
else
        err <= 1;

4'd6:
if(input_valid[0])
    res <={{N{1'b0}},~OPA};
else
        err <= 1;

4'd7:
if(input_valid[1])
    res <={{N{1'b0}}, ~OPB};
else
        err <= 1;

4'd8:
if(input_valid[0])
    res <={{N{1'b0}}, OPA >> 1};
else
        err <= 1;

4'd9:
if(input_valid[0])
    res <={{N{1'b0}}, OPA << 1};
else
        err <= 1;

4'd10:
if(input_valid[1])
    res <={{N{1'b0}}, OPB >> 1};
else
        err <= 1;

4'd11:
if(input_valid[1])
    res <= {{N{1'b0}},OPB << 1};
else
        err <= 1;

4'd12:
begin
    if(input_valid==2'b11)
    begin
        if(OPB[7:4]!=0)
	  err<=1;
	else
	case (OPB[2:0])

3'b000 : res = {{N{1'b0}},OPA};

3'b001 : res = {{N{1'b0}},OPA[6:0],OPA[7]};

3'b010 : res = {{N{1'b0}},OPA[5:0],OPA[7:6]};

3'b011 : res = {{N{1'b0}},OPA[4:0],OPA[7:5]};

3'b100 : res = {{N{1'b0}},OPA[3:0],OPA[7:4]};

3'b101 : res = {{N{1'b0}},OPA[2:0],OPA[7:3]};

3'b110 : res = {{N{1'b0}},OPA[1:0],OPA[7:2]};

3'b111 : res = {{N{1'b0}},OPA[0],OPA[7:1]};

endcase
    end
    else
        err <= 1;
end

4'd13:
begin
    if(input_valid==2'b11)
    begin
	if(OPB[7:4]!=0)
	  err<=1;
	else
	  case (OPB[2:0])

3'b000 : res = {{N{1'b0}},OPA};

3'b001 : res = {{N{1'b0}},OPA[0],OPA[7:1]};

3'b010 : res = {{N{1'b0}},OPA[1:0],OPA[7:2]};

3'b011 : res = {{N{1'b0}},OPA[2:0],OPA[7:3]};

3'b100 : res = {{N{1'b0}},OPA[3:0],OPA[7:4]};

3'b101 : res = {{N{1'b0}},OPA[4:0],OPA[7:5]};

3'b110 :res = {{N{1'b0}},OPA[5:0],OPA[7:6]};

3'b111 : res = {{N{1'b0}},OPA[6:0],OPA[7]};

endcase
    
    end
    else
        err <= 1;
end
default:err<=1'b1;
endcase

end

end

endmodule

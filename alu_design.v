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

reg [N-1:0] rot;
reg [1:0] count;
always @(posedge clk or posedge rst)
begin
    if(rst)
        count <= 0;
    else if(CE)
    begin
        if(cmd==4'd9 || cmd==4'd10)
        begin
            if(count < 3)
                count <= count + 1;
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
        cout <= (OPA + OPB) >> N;
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
        cout <= (OPA >= OPB);
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
        cout <= (OPA + OPB + cin) >> N;
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
        cout <= ({1'b0,OPA} >= ({1'b0,OPB}+cin));
        OFLOW <= ({1'b0,OPA} < ({1'b0,OPB}+cin));
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end
4'd4:
begin
    if(input_valid[0])
    begin
        res <= OPA + 1;
        cout <= (OPA == 8'hFF);
        OFLOW <= 0;
        {err,G,E,L} <= 0;
    end
    else
        err <= 1;
end
4'd5:
begin
    if(input_valid[0])
    begin
        res <= OPA - 1;
        cout <= (OPA != 0);
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
        res <= OPB + 1;
        cout <= (OPB == 8'hFF);
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
        res <= OPB - 1;
        cout <= (OPB != 0);
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
        if(count==2'b10)
            res <= (OPA+1)*(OPB+1);
    end
    else
        err <= 1;
end
4'd10:
begin
    if(input_valid==2'b11)
    begin
        if(count==2'b10)
        begin
            res <= (OPA<<1)*OPB;
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
        if(count==2'b10)
        begin
            res <= $signed(OPA) + $signed(OPB);

            OFLOW <= (
                        (OPA[N-1] == OPB[N-1]) &&
                        (res[N-1] != OPA[N-1])
                      );

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
4'd12:
begin
    if(input_valid==2'b11)
    begin
        if(count==2'b10)
        begin
            res <= $signed(OPA) - $signed(OPB);

            OFLOW <= (
                        (OPA[N-1] != OPB[N-1]) &&
                        (res[N-1] != OPA[N-1])
                      );
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
endcase
end
else
begin
{err,OFLOW,cout,G,E,L} <= 0;
case(cmd)
4'd0:
if(input_valid==2'b11)
    res <= OPA & OPB;
4'd1:
if(input_valid==2'b11)
    res <= ~(OPA & OPB);
4'd2:
if(input_valid==2'b11)
    res <= OPA | OPB;
4'd3:
if(input_valid==2'b11)
    res <= ~(OPA | OPB);
4'd4:
if(input_valid==2'b11)
    res <= OPA ^ OPB;
4'd5:
if(input_valid==2'b11)
    res <= ~(OPA ^ OPB);
4'd6:
if(input_valid[0])
    res <= ~OPA;
4'd7:
if(input_valid[1])
    res <= ~OPB;
4'd8:
if(input_valid[0])
    res <= OPA >> 1;
4'd9:
if(input_valid[0])
    res <= OPA << 1;
4'd10:
if(input_valid[1])
    res <= OPB >> 1;
4'd11:
if(input_valid[1])
    res <= OPB << 1;
4'd12:
begin
    if(input_valid==2'b11)
    begin
        rot = (OPA << (OPB % N)) |
              (OPA >> (N - (OPB % N)));

        res <= rot;
    end
    else
        err <= 1;
end
4'd13:
begin
    if(input_valid==2'b11)
    begin
        rot = (OPA >> (OPB % N)) |
              (OPA << (N - (OPB % N)));
        res <= rot;
    end
    else
        err <= 1;
end
endcase
end
end
endmodule

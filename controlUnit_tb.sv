module controlUnit_tb();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 10;
logic clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

logic clk,rstN,start,Zout;
logic[IR_WIDTH-1:0]ins;
logic [2:0]aluOp;
logic [3:0]incReg;    // {PC, RC, RP, RQ}
logic [9:0]wrEnReg;   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}
logic [3:0]busSel;
logic dMemWrEn,ZWrEn;
logic done,ready;

controlUnit dut(.*);

localparam  //IDLE	= 8'd0,   //instruction set
            NOP	=8'd0,
            ENDOP=	8'd1,
            CLAC=	8'd2,
            LDIAC=	8'd3,
            LDAC=	8'd4,
            STR=	8'd5,
            STIR=	8'd6,
            JUMP=	8'd7,
            JMPNZ=	8'd8,
            JMPZ=	8'd9,
            MUL	=8'd10,
            ADD	=8'd11,
            SUB	=8'd12,
            INCAC	=8'd13,
            MV_RL_AC=	{4'd1,4'd15},
            MV_RP_AC=	{4'd2,4'd15},
            MV_RQ_AC=	{4'd3,4'd15},
            MV_RC_AC=	{4'd4,4'd15},
            MV_R_AC =	{4'd5,4'd15},
            MV_R1_AC=	{4'd6,4'd15},
            MV_AC_RP=	{4'd7,4'd15},
            MV_AC_RQ=	{4'd8,4'd15},
            MV_AC_RL=	{4'd9,4'd15};

logic [7:0]instructions[0:22] = '{
                                    NOP	,
                                    ENDOP,
                                    CLAC,
                                    LDIAC,
                                    LDAC,
                                    STR,
                                    STIR,
                                    JUMP,
                                    JMPNZ,
                                    JMPZ,
                                    MUL	,
                                    ADD	,
                                    SUB	,
                                    INCAC,
                                    MV_RL_AC,
                                    MV_RP_AC,
                                    MV_RQ_AC,
                                    MV_RC_AC,
                                    MV_R_AC ,
                                    MV_R1_AC,
                                    MV_AC_RP,
                                    MV_AC_RQ,
                                    MV_AC_RL
                                };



initial begin
    @(posedge clk);
    rstN <= 1'b1;
    
end
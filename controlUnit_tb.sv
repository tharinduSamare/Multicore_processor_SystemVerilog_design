module controlUnit_tb import details::*;();

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

localparam IR_WIDTH = 8;

logic rstN,start,Zout;
logic[IR_WIDTH-1:0]ins;
alu_op_t aluOp;
logic [3:0]incReg;    // {PC, RC, RP, RQ}
logic [9:0]wrEnReg;   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}
bus_in_sel_t busSel;
logic DataMemWrEn,ZWrEn;
logic done,ready;


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




localparam // time duration for each instruction to exicute
        NOP_time_duration 	    =   4,
        ENDOP_time_duration     =   4,
        CLAC_time_duration      =   4,
        LDIAC_time_duration     =   8,
        LDAC_time_duration      =   6,
        STR_time_duration       =   6,
        STIR_time_duration      =   8,
        JUMP_time_duration      =   6,
        JMPNZ_Y_time_duration   =   6,
        JMPNZ_N_time_duration   =   4,
        JMPZ_Y_time_duration    =   6,
        JMPZ_N_time_duration    =   4,
        MUL_time_duration	    =   4,
        ADD_time_duration	    =   4,
        SUB_time_duration	    =   4,
        INCAC_time_duration	    =   4,
        MV_RL_AC_time_duration  =   4,
        MV_RP_AC_time_duration  =   4,
        MV_RQ_AC_time_duration  =   4,
        MV_RC_AC_time_duration  =   4,
        MV_R_AC_time_duration   =   4,
        MV_R1_AC_time_duration  =   4,
        MV_AC_RP_time_duration  =   4,
        MV_AC_RQ_time_duration  =   4,
        MV_AC_RL_time_duration  =   4;


controlUnit #(.IR_WIDTH(IR_WIDTH)) dut(.*);


task automatic test_instruction(
    input int duration,
    input logic [IR_WIDTH-1:0] instruction, 
    input logic Z_value,
    ref logic [IR_WIDTH-1:0] ins,
    ref logic Zout
);
    
    @(posedge clk);
    ins = instruction;
    Zout = Z_value;

    #(duration * CLK_PERIOD);
    // repeat(duration)@(posedge clk);

endtask


initial begin
    @(posedge clk);
    rstN <= 1'b0;
    @(posedge clk);
    rstN <= 1'b1;
    start <= 1'b1;

    ////// test NOP
    test_instruction(.duration(NOP_time_duration), .instruction(NOP), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ///// test ENDOP
    // test_instruction(.duration(ENDOP_time_duration), .instruction(ENDOP), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ///// test CLAC
    test_instruction(.duration(CLAC_time_duration), .instruction(CLAC),  .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ///// test LDIAC
    test_instruction(.duration(LDIAC_time_duration), .instruction(LDIAC), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ////// test LDAC
    test_instruction(.duration(LDAC_time_duration), .instruction(LDAC), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ////// test STR
    test_instruction(.duration(STR_time_duration), .instruction(STR), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ////// test STIR
    test_instruction(.duration(STIR_time_duration), .instruction(STIR), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ////// test JUMP
    test_instruction(.duration(JUMP_time_duration), .instruction(JUMP), .Z_value(1'bX), .ins(ins), .Zout(Zout));

    ////// test JMPNZ_Y
    test_instruction(.duration(JMPNZ_Y_time_duration), .instruction(JMPNZ), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test JMPNZ_N
    test_instruction(.duration(JMPNZ_N_time_duration), .instruction(JMPNZ), .Z_value(1'b1), .ins(ins), .Zout(Zout));

    ////// test JMPZ_Y
    test_instruction(.duration(JMPZ_Y_time_duration), .instruction(JMPZ), .Z_value(1'b1), .ins(ins), .Zout(Zout));

    ////// test JMPZ_N
    test_instruction(.duration(JMPZ_N_time_duration), .instruction(JMPZ), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MUL
    test_instruction(.duration(MUL_time_duration), .instruction(MUL), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test ADD
    test_instruction(.duration(ADD_time_duration), .instruction(ADD), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test SUB
    test_instruction(.duration(SUB_time_duration), .instruction(SUB), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test INCAC
    test_instruction(.duration(INCAC_time_duration), .instruction(INCAC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_RL_AC
    test_instruction(.duration(MV_RL_AC_time_duration), .instruction(MV_RL_AC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_RP_AC
    test_instruction(.duration(MV_RP_AC_time_duration), .instruction(MV_RP_AC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_RQ_AC
    test_instruction(.duration(MV_RQ_AC_time_duration), .instruction(MV_RQ_AC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_RC_AC
    test_instruction(.duration(MV_RC_AC_time_duration), .instruction(MV_RC_AC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_R_AC
    test_instruction(.duration(MV_R_AC_time_duration), .instruction(MV_R_AC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_R1_AC
    test_instruction(.duration(MV_R1_AC_time_duration), .instruction(MV_R1_AC), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_AC_RP
    test_instruction(.duration(MV_AC_RP_time_duration), .instruction(MV_AC_RP), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_AC_RQ
    test_instruction(.duration(MV_AC_RQ_time_duration), .instruction(MV_AC_RQ), .Z_value(1'b0), .ins(ins), .Zout(Zout));

    ////// test MV_AC_RL
    test_instruction(.duration(MV_AC_RL_time_duration), .instruction(MV_AC_RL), .Z_value(1'b0), .ins(ins), .Zout(Zout));

end

endmodule : controlUnit_tb
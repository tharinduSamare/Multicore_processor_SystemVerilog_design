module controlUnit_tb import details::*;();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 20;
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
ISA_t instruction;
alu_op_t aluOp;
inc_reg_t incReg;    // {PC, RC, RP, RQ}
wrEnReg_t wrEnReg;   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}
bus_in_sel_t busSel;
logic DataMemWrEn,ZWrEn;
logic done,ready;


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

////////// for easy readability (start) //////////////

///////// for easy readability (end) ////////////////


task automatic test_instruction(
    input int duration,
    input ISA_t ins, 
    input logic Z_value,
    ref ISA_t instruction,
    ref logic Zout
);
    
    @(posedge clk);
    instruction = ins;
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
    test_instruction(.duration(NOP_time_duration), .ins(NOP), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ///// test CLAC
    test_instruction(.duration(CLAC_time_duration), .ins(CLAC),  .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ///// test LDIAC
    test_instruction(.duration(LDIAC_time_duration), .ins(LDIAC), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ////// test LDAC
    test_instruction(.duration(LDAC_time_duration), .ins(LDAC), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ////// test STR
    test_instruction(.duration(STR_time_duration), .ins(STR), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ////// test STIR
    test_instruction(.duration(STIR_time_duration), .ins(STIR), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ////// test JUMP
    test_instruction(.duration(JUMP_time_duration), .ins(JUMP), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

    ////// test JMPNZ_Y
    test_instruction(.duration(JMPNZ_Y_time_duration), .ins(JMPNZ), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test JMPNZ_N
    test_instruction(.duration(JMPNZ_N_time_duration), .ins(JMPNZ), .Z_value(1'b1), .instruction(instruction), .Zout(Zout));

    ////// test JMPZ_Y
    test_instruction(.duration(JMPZ_Y_time_duration), .ins(JMPZ), .Z_value(1'b1), .instruction(instruction), .Zout(Zout));

    ////// test JMPZ_N
    test_instruction(.duration(JMPZ_N_time_duration), .ins(JMPZ), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MUL
    test_instruction(.duration(MUL_time_duration), .ins(MUL), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test ADD
    test_instruction(.duration(ADD_time_duration), .ins(ADD), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test SUB
    test_instruction(.duration(SUB_time_duration), .ins(SUB), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test INCAC
    test_instruction(.duration(INCAC_time_duration), .ins(INCAC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_RL_AC
    test_instruction(.duration(MV_RL_AC_time_duration), .ins(MV_RL_AC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_RP_AC
    test_instruction(.duration(MV_RP_AC_time_duration), .ins(MV_RP_AC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_RQ_AC
    test_instruction(.duration(MV_RQ_AC_time_duration), .ins(MV_RQ_AC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_RC_AC
    test_instruction(.duration(MV_RC_AC_time_duration), .ins(MV_RC_AC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_R_AC
    test_instruction(.duration(MV_R_AC_time_duration), .ins(MV_R_AC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_R1_AC
    test_instruction(.duration(MV_R1_AC_time_duration), .ins(MV_R1_AC), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_AC_RP
    test_instruction(.duration(MV_AC_RP_time_duration), .ins(MV_AC_RP), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_AC_RQ
    test_instruction(.duration(MV_AC_RQ_time_duration), .ins(MV_AC_RQ), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ////// test MV_AC_RL
    test_instruction(.duration(MV_AC_RL_time_duration), .ins(MV_AC_RL), .Z_value(1'b0), .instruction(instruction), .Zout(Zout));

    ///// test ENDOP
    test_instruction(.duration(ENDOP_time_duration), .ins(ENDOP), .Z_value(1'bX), .instruction(instruction), .Zout(Zout));

end

initial begin         // simulation stop condition
    forever begin
        @(posedge clk);
        if (done) begin
            #(5*CLK_PERIOD);
            $stop;
        end
    end
end

endmodule : controlUnit_tb
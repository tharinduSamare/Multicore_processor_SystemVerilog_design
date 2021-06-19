module controlUnit import details::*;
#(
    parameter IR_WIDTH = 8
)
(
    input  logic clk,rstN,start,Zout,
    input  ISA_t instruction,
    output alu_op_t aluOp,
    output inc_reg_t incReg,    // {PC, RC, RP, RQ}
    output wrEnReg_t wrEnReg,   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}
    output bus_in_sel_t busSel,
    output logic DataMemWrEn,ZWrEn,
    output logic done,ready
);

typedef enum logic [5:0] {
    IDLE = 6'd0,  //states

    NOP1 = 6'd1,

    ENDOP1 = 6'd2,

    CLAC1 = 6'd3,

    FETCH_DELAY1 = 6'd37,         /////************** (extra_delay for memory read)
    FETCH1 = 6'd4,
    FETCH2 = 6'd5,

    LDIAC_DELAY1 =  6'd38,         /////************** (extra_delay for memory read)
    LDIAC1 = 6'd6,
    LDIAC2 = 6'd7,
    LDIAC_DELAY2 = 6'd39,         /////************** (extra_delay for memory read)
    LDIAC3 = 6'd8,

    LDAC1 = 6'd9,
    LDAC_DELAY1 = 6'd40,         /////************** (extra_delay for memory read)
    LDAC2 = 6'd10,

    STIR_DELAY1 = 6'd41,         /////************** (extra_delay for memory read)
    STIR1 = 6'd11,
    STIR2 = 6'd12,
    STIR_DELAY2 = 6'd42,         /////************** (extra_delay for memory write)
    STIR3 = 6'd13,

    STR1 = 6'd14,
    STR_DELAY1 = 6'd43,         /////************** (extra_delay for memory write)
    STR2 = 6'd15,

    JUMP_DELAY1 = 6'd44,         /////************** (extra_delay for memory read)
    JUMP1 = 6'd16,
    JUMP2 = 6'd17,
    
    JMPNZY_DILAY1 = 6'd45,         /////************** (extra_delay for memory read)
    JMPNZY1 = 6'd18,
    JMPNZY2 = 6'd19,
    JMPNZN1 = 6'd20,

    JMPZY_DELAY1 = 6'd46,         /////************** (extra_delay for memory read)
    JMPZY1 = 6'd21,
    JMPZY2 = 6'd22,
    JMPZN1 = 6'd23,

    MUL1 = 6'd24,

    ADD1 = 6'd25,

    SUB1 = 6'd26,

    INCAC1 = 6'd27,

    MV_RL_AC1 = 6'd28,

    MV_RP_AC1 = 6'd29,

    MV_RQ_AC1 = 6'd30,

    MV_RC_AC1 = 6'd31,

    MV_R_AC1 = 6'd32,

    MV_R1_AC1 = 6'd33,

    MV_AC_RP1 = 6'd34,

    MV_AC_RQ1 = 6'd35,

    MV_AC_RL1 = 6'd36
} states_t;

states_t currentState, nextState;

always_ff @(posedge clk) begin
    if (~rstN) begin
        currentState <= IDLE;
    end
    else begin
        currentState <= nextState;
    end
end

////////////next state calculation
always_comb begin 
    nextState = currentState;
    unique case(currentState)
        IDLE : begin
            if (start)
                nextState <= FETCH1;
            else
                nextState <= IDLE;
        end

        NOP1 : nextState <= FETCH1;

        ENDOP1 : nextState <= ENDOP1;

        CLAC1 : nextState <= FETCH1;

        FETCH_DELAY1 : nextState <= FETCH1;        // extra_delay for memory read
        FETCH1 : nextState <= FETCH2;
        FETCH2 : begin
            unique case(instruction)
                NOP: nextState <= NOP1;
                ENDOP: nextState <= ENDOP1;
                CLAC: nextState <= CLAC1;
                LDIAC: nextState <= LDIAC_DELAY1; 
                LDAC: nextState <= LDAC1;
                STR: nextState <= STR1;
                STIR: nextState <= STIR_DELAY1;  // extra_delay for memory read
                JUMP: nextState <= JUMP_DELAY1;  // extra_delay for memory read
                JMPNZ: nextState <= (Zout == 0)? JMPNZY_DILAY1 : JMPNZN1; // extra_delay for memory read
                JMPZ: nextState <= (Zout == 1)? JMPZY_DELAY1 : JMPZN1;  // extra_delay for memory read
                MUL: nextState <= MUL1;
                ADD: nextState <= ADD1;
                SUB: nextState <= SUB1;
                INCAC: nextState <= INCAC1;
                MV_RL_AC: nextState <= MV_RL_AC1;
                MV_RP_AC: nextState <= MV_RP_AC1;
                MV_RQ_AC: nextState <= MV_RQ_AC1;
                MV_RC_AC: nextState <= MV_RC_AC1;
                MV_R_AC: nextState <= MV_R_AC1;
                MV_R1_AC: nextState <= MV_R1_AC1;
                MV_AC_RP: nextState <= MV_AC_RP1;
                MV_AC_RQ: nextState <= MV_AC_RQ1;
                MV_AC_RL: nextState <= MV_AC_RL1;
                default: nextState <= IDLE;
            endcase
        end

        LDIAC_DELAY1 : nextState <= LDIAC1;        // extra_delay for memory read
        LDIAC1 : nextState <= LDIAC2;
        LDIAC2 : nextState <= LDIAC_DELAY2;
        LDIAC_DELAY2 : nextState <= LDIAC3;       // extra_delay for memory read
        LDIAC3 : nextState <= FETCH_DELAY1;

        LDAC1 : nextState <= LDAC_DELAY1;
        LDAC_DELAY1 : nextState <= LDAC2;        // extra_delay for memory read
        LDAC2 : nextState <= FETCH_DELAY1;

        STIR_DELAY1 : nextState <= STIR1;       // extra_delay for memory read
        STIR1 : nextState <= STIR2;
        STIR2 : nextState <= STIR3;
        // STIR_DELAY2 : nextState <= STIR3;         // extra_delay for memory write
        STIR3 : nextState <= FETCH_DELAY1;

        STR1 : nextState <= STR2;
        // STR_DELAY1 : nextState <= STR2;         // extra_delay for memory write
        STR2 : nextState <= FETCH1;

        JUMP_DELAY1 : nextState <= JUMP1;        // extra_delay for memory read
        JUMP1 : nextState <= JUMP2;
        JUMP2 : nextState <= FETCH_DELAY1;
        
        JMPNZY_DILAY1 : nextState <= JMPNZY1;        // extra_delay for memory read
        JMPNZY1 : nextState <= JMPNZY2;
        JMPNZY2 : nextState <= FETCH_DELAY1;
        JMPNZN1 : nextState <= FETCH_DELAY1;

        JMPZY_DELAY1 : nextState <= JMPZY1;         // extra_delay for memory read
        JMPZY1 : nextState <= JMPZY2;
        JMPZY2 : nextState <= FETCH_DELAY1;
        JMPZN1 : nextState <= FETCH_DELAY1;

        MUL1 : nextState <= FETCH_DELAY1;

        ADD1 : nextState <= FETCH_DELAY1;

        SUB1 : nextState <= FETCH_DELAY1;

        INCAC1 : nextState <= FETCH_DELAY1;

        MV_RL_AC1 : nextState <= FETCH_DELAY1;

        MV_RP_AC1 : nextState <= FETCH_DELAY1;

        MV_RQ_AC1 : nextState <= FETCH_DELAY1;

        MV_RC_AC1 : nextState <= FETCH_DELAY1;

        MV_R_AC1 : nextState <= FETCH_DELAY1;

        MV_R1_AC1 : nextState <= FETCH_DELAY1;

        MV_AC_RP1 : nextState <= FETCH_DELAY1;

        MV_AC_RQ1 : nextState <= FETCH_DELAY1;

        MV_AC_RL1 : nextState <= FETCH_DELAY1;
        default  : nextState <= IDLE;
    endcase    
end

///////////logic within a state
always_comb begin 
    unique case(currentState)
        IDLE: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        NOP1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        ENDOP1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        CLAC1: begin
            aluOp <= clr_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        FETCH_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        FETCH1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        FETCH2: begin
            aluOp <= idle_alu;
            incReg <= PC_inc;
            wrEnReg <= no_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        LDIAC_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        LDIAC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        LDIAC2: begin
            aluOp <= idle_alu;
            incReg <= PC_inc;
            wrEnReg <= AR_wrEn;
            busSel <= IR_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        LDIAC_DELAY2: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        LDIAC3: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        LDAC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= AR_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        LDAC_DELAY1: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        LDAC2: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        STR1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= AR_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        STR_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
        end

        STR2: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
        end

        STIR_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        STIR1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        STIR2: begin
            aluOp <= idle_alu;
            incReg <= PC_inc;
            wrEnReg <= AR_wrEn;
            busSel <= IR_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        STIR_DELAY2: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
        end

        STIR3: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
        end

        JUMP_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JUMP1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JUMP2: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= PC_wrEn;
            busSel <= IR_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPNZY_DILAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPNZY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPNZY2: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= PC_wrEn;
            busSel <= IR_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPNZN1: begin
            aluOp <= idle_alu;
            incReg <= PC_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPZY_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPZY1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= IR_wrEn;
            busSel <= DMem_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPZY2: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= PC_wrEn;
            busSel <= IR_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        JMPZN1: begin
            aluOp <= idle_alu;
            incReg <= PC_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MUL1: begin
            aluOp <= mul_alu;
            incReg <= RC_RP_RQ_inc;
            wrEnReg <= AC_wrEn;
            busSel <= R1_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        ADD1: begin
            aluOp <= add_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= R_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        SUB1: begin
            aluOp <= sub_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= RC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        INCAC1: begin
            aluOp <= inc_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        MV_RL_AC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= RL_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MV_RP_AC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= RP_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MV_RQ_AC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= RQ_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MV_RC_AC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= RC_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MV_R_AC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= R_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MV_R1_AC1: begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= R1_wrEn;
            busSel <= AC_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end

        MV_AC_RP1: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= RP_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        MV_AC_RQ1: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= RQ_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        MV_AC_RL1: begin
            aluOp <= pass_alu;
            incReg <= no_inc;
            wrEnReg <= AC_wrEn;
            busSel <= RL_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
        end

        default : begin
            aluOp <= idle_alu;
            incReg <= no_inc;
            wrEnReg <= no_wrEn;
            busSel <= idle_bus;
            DataMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
        end
    endcase    
end

assign done = (currentState == ENDOP1)?1'b1:1'b0;
assign ready = (currentState == IDLE)? 1'b1:1'b0;

endmodule :controlUnit
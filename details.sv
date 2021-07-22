package details;
localparam IR_WIDTH = 8;

typedef enum logic [2:0]{
    clr_alu = 3'd0,   //alu operations
    pass_alu = 3'd1,
    add_alu =  3'd2,
    sub_alu =  3'd3,
    mul_alu =  3'd4,
    inc_alu =  3'd5,
    idle_alu = 3'd6
} alu_op_t;

typedef enum logic [3:0]{
    DMem_bus = 4'b0,   //multiplexer
    R_bus = 4'd1,
    IR_bus = 4'd2,
    RL_bus = 4'd3,
    RC_bus = 4'd4,
    RP_bus = 4'd5,
    RQ_bus = 4'd6,
    R1_bus = 4'd7,
    AC_bus = 4'd8,
    idle_bus = 4'd9
} bus_in_sel_t;

typedef enum logic [IR_WIDTH-1:0]{
    NOP 	    =   8'd0,
    ENDOP       =	8'd1,
    CLAC        =	8'd2,
    LDIAC       =	8'd3,
    LDAC        =	8'd4,
    STR         =	8'd5,
    STIR        =	8'd6,
    JUMP        =	8'd7,
    JMPNZ       =	8'd8,
    JMPZ        =	8'd9,
    MUL	        =   8'd10,
    ADD	        =   8'd11,
    SUB	        =   8'd12,
    INCAC	    =   8'd13,
    MV_RL_AC    =	{4'd1,4'd15},
    MV_RP_AC    =	{4'd2,4'd15},
    MV_RQ_AC    =	{4'd3,4'd15},
    MV_RC_AC    =	{4'd4,4'd15},
    MV_R_AC     =	{4'd5,4'd15},
    MV_R1_AC    =	{4'd6,4'd15},
    MV_AC_RP    =	{4'd7,4'd15},
    MV_AC_RQ    =	{4'd8,4'd15},
    MV_AC_RL    =	{4'd9,4'd15}
} ISA_t;    

typedef enum logic [3:0] { 
    no_inc = 4'b0000,
    PC_inc = 4'b1000,
    RC_inc = 4'b0100,
    RP_inc = 4'b0010,
    RQ_inc = 4'b0001,
    RC_RP_RQ_inc = 4'b0111
} inc_reg_t;

typedef enum logic [9:0] { 
    no_wrEn = 10'b0000000000,
    AR_wrEn = 10'b1000000000,
    R_wrEn  = 10'b0100000000,
    PC_wrEn = 10'b0010000000,
    IR_wrEn = 10'b0001000000,
    RL_wrEn = 10'b0000100000,
    RC_wrEn = 10'b0000010000,
    RP_wrEn = 10'b0000001000,
    RQ_wrEn = 10'b0000000100,
    R1_wrEn = 10'b0000000010,
    AC_wrEn = 10'b0000000001
} wrEnReg_t;

typedef enum logic [0:0]{
    ins_mem = 1'b0,
    data_mem = 1'b1
} mem_t;

typedef enum logic[0:0]{
    no = 1'b0,
    yes = 1'b1
} mem_init_t;


endpackage
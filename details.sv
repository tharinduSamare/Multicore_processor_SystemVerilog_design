package details;
    typedef enum logic [2:0]{
        clr_alu = 3'd0,   //alu operations
        pass_alu = 3'd1,
        add_alu =  3'd2,
        sub_alu =  3'd3,
        mul_alu =  3'd4,
        inc_alu =  3'd5,
        idle_alu = 3'dx
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



endpackage
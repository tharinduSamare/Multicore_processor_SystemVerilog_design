module multiplexer import details::*;
#(
    parameter WIDTH = 12,
    parameter IR_WIDTH = 8
)
(
    input bus_in_sel_t selectIn,
    input logic [WIDTH-1:0]DMem, R, RL, RC, RP, RQ, R1, AC,
    input logic [IR_WIDTH-1:0]IR,
    output logic [WIDTH-1:0]busOut
);

always_comb begin 
    unique case(selectIn)
        DMem_bus: busOut = DMem;
        R_bus: busOut = R;
        IR_bus: busOut = WIDTH'(IR);
        RL_bus: busOut = RL;
        RC_bus: busOut = RC;
        RP_bus: busOut = RP;
        RQ_bus: busOut = RQ;
        R1_bus: busOut = R1;
        AC_bus: busOut = AC;
        idle_bus: busOut = '0;
        default: busOut = '0;
    endcase    
end

endmodule:multiplexer

module alu import details::*;
#(parameter WIDTH = 12)
(
    input logic signed [WIDTH-1:0]a,b,
    input alu_op_t selectOp,
    output logic signed [WIDTH-1:0]c
);

// localparam  clr = 3'd0,
//             pass = 3'd1,
//             add =  3'd2,
//             sub =  3'd3,
//             mul =  3'd4,
//             inc =  3'd5,
//             idle = 3'dx;

always_comb begin
    unique case(selectOp)
        clr_alu : c = 'd0;
        pass_alu: c = b;
        add_alu : c = a+b;
        sub_alu : c = a-b;
        mul_alu : c = a*b;
        inc_alu : c = a+WIDTH'(signed'(1));
        default: c = '0;
    endcase
end

endmodule:alu
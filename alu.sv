module alu import details::*;
#(parameter WIDTH = 12)
(
    input logic signed [WIDTH-1:0]a,b,
    input alu_op_t selectOp,
    output logic signed [WIDTH-1:0]c
);

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
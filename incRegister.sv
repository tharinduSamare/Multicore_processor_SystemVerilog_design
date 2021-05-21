module incRegister
#(parameter WIDTH = 12)
(
    input logic [WIDTH-1:0]dataIn,
    input logic wrEn, rstN, clk, incEn,
    output logic [WIDTH-1:0]dataOut
);

logic [WIDTH-1:0] value;

always_ff @(posedge clk) begin
    if (~rstN) value <= '0;
    else if (wrEn) value <= dataIn;
    if (incEn) value <= value+ WIDTH'(1); 
end

assign dataOut = value;

endmodule:incRegister
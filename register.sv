module register
#(parameter WIDTH = 12)
(
    input logic [WIDTH-1:0] dataIn,
    input logic clk,rstN,wrEn,
    output logic [WIDTH-1:0]dataOut
);

logic [WIDTH-1:0] value;

always_ff @( posedge clk ) begin
    if (~rstN) value <= '0;
    else if (wrEn) value <= dataIn;
end

assign dataOut = value;
endmodule : register
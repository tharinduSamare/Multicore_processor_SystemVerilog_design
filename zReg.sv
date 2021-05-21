module zReg
#(parameter WIDTH = 12)
(
    input logic [WIDTH-1:0]dataIn,
    input logic clk, rstN, wrEn,
    output logic Zout
);

logic value;

always_ff @( posedge clk ) begin 
    if (~rstN) value <= 1'b0;
    else if (wrEn) begin
        if (dataIn == 0) value <= 1'b1;
        else value <= 1'b0;
    end    
end

assign Zout = value;

endmodule:zReg

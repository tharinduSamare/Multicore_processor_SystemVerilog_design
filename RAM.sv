module RAM
#(
    parameter WIDTH = 12,
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)
(
    input logic clk, wrEn,
    input logic [WIDTH-1:0]dataIn,
    input logic [ADDR_WIDTH-1:0]addr,
    output logic [WIDTH-1:0]dataOut
);


logic [ADDR_WIDTH-1:0]addr_reg;

logic [WIDTH-1:0]memory[0:DEPTH-1] ;

always_ff @(posedge clk) begin
    addr_reg <= addr;
    if (wrEn) begin
        memory[addr] <= dataIn;   // write requires only 1 clk cyle. 
    end
end
assign dataOut = memory[addr_reg];   // address is registered. Need 2 clk cycles to read.

endmodule : RAM

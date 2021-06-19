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

logic wrEn_reg;
logic [WIDTH-1:0]dataIn_reg;
logic [ADDR_WIDTH-1:0]addr_reg;

logic [WIDTH-1:0]memory[0:DEPTH-1] ;

always_ff @(posedge clk) begin
    addr_reg <= addr;
    if (wrEn) begin
        memory[addr] <= dataIn;
    end
end
assign dataOut = memory[addr_reg];


endmodule : RAM

module RAM
#(
    parameter WIDTH = 12,
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)
(
    input logic clk,wrEn,
    input logic [WIDTH-1:0]dataIn,
    input logic [ADDR_WIDTH-1:0]addr,
    output logic [WIDTH-1:0]dataOut
);

logic [WIDTH-1:0]memory[0:DEPTH-1];

always_ff @( posedge clk ) begin 
    if (wrEn) 
        memory[addr] <= dataIn;
end

always_ff @(negedge clk) begin   //synchronous read at negedge
    dataOut <= memory[addr];
end


endmodule : RAM
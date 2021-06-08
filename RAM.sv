// module RAM
// #(
//     parameter WIDTH = 12,
//     parameter DEPTH = 256,
//     parameter ADDR_WIDTH = $clog2(DEPTH)
// )
// (
//     input logic clk,wrEn,
//     input logic [WIDTH-1:0]dataIn,
//     input logic [ADDR_WIDTH-1:0]addr,
//     output logic [WIDTH-1:0]dataOut
// );

// logic [WIDTH-1:0]memory[0:DEPTH-1];

// always_ff @( posedge clk ) begin 
//     if (wrEn) 
//         memory[addr] <= dataIn;
// end

// always_ff @(negedge clk) begin   //synchronous read at negedge
//     dataOut <= memory[addr];
// end


// endmodule : RAM

module RAM_2
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

logic [WIDTH-1:0]memory[0:DEPTH-1];

always_ff @( posedge clk) begin
    wrEn_reg <= wrEn;
    addr_reg <= addr;
    dataIn_reg <= dataIn;
end

always_ff @(posedge clk) begin
    if (wrEn_reg) begin
        memory[addr_reg] <= dataIn_reg;
    end
end

assign dataOut = memory[addr_reg];

endmodule : RAM_2

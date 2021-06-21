module DATA_RAM import details::*;
#( 
    parameter mem_init_t mem_init = no, 
    parameter WIDTH = 12,
    parameter DEPTH = 4096,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)
(
    input logic clk, wrEn,
    input logic [WIDTH-1:0]dataIn,
    input logic [ADDR_WIDTH-1:0]addr,
    output logic [WIDTH-1:0]dataOut,

    input logic processDone   // need only for simulation (to get the memory at the end)
);


logic [ADDR_WIDTH-1:0]addr_reg;

logic [WIDTH-1:0]memory[0:DEPTH-1] ;

/// initialize memory for simulation  /////////
initial begin
    if (mem_init == yes) begin
        $readmemb("../../4_data_mem_tb.txt", memory);
    end
end

always_comb begin
    if (processDone) begin
        $writememb("../../11_data_mem_out.txt", memory);
    end
end

///////////////////////////////////////////////

always_ff @(posedge clk) begin
    addr_reg <= addr;
    if (wrEn) begin
        memory[addr] <= dataIn;   // write requires only 1 clk cyle. 
    end
end
assign dataOut = memory[addr_reg];   // address is registered. Need 2 clk cycles to read.

endmodule : DATA_RAM

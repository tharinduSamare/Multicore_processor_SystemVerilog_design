class RAM_class #(parameter WIDTH, DEPTH);

localparam ADDR_WIDTH = $clog2(DEPTH);

typedef logic [WIDTH-1:0]  data_t;
typedef logic [ADDR_WIDTH-1:0] addr_t;

logic [WIDTH-1:0] RAM [0:DEPTH-1];
// logic [ADDR_WIDTH-1:0] addr;


function initialize_full_memory(input logic [WIDTH-1:0]initial_vals[0:DEPTH-1]);
    RAM = initial_vals;
endfunction

function initialize_singal_memory_location(input data_t value, input addr_t addr);
    RAM[addr] = value;
endfunction

task Read_memory(input addr_t addr, output data_t value);        // if needed read time delay can be added
    value = RAM[addr];
endtask

task Write_memory(input addr_t addr, input data_t data, input logic wrEn, input ref clk); // if needed write time delay can be added
    @(posedge clk);
    if (wrEn) begin
        RAM[addr] = data;
    end
endtask

endclass


module processor_tb import details::*;();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 10;
logic clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam REG_WIDTH = 12;
localparam INS_WIDTH = 8;
localparam INS_DEPTH = 256;
localparam DATA_DEPTH = 4096;

logic rstN,start;
logic [REG_WIDTH-1:0]DataMemOut;
logic [INS_WIDTH-1:0]InsMemOut;
logic  [REG_WIDTH-1:0]dataMemAddr,DataMemIn;
logic  [INS_WIDTH-1:0]insMemAddr;
logic  DataMemWrEn;
logic  done,ready;

processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH))dut(.*);

///// initialize instruction and data memory /////////
RAM_class #(.REG_WIDTH(INS_WIDTH), .DEPTH(INS_DEPTH)) ins_mem = new;
RAM_class #(.REG_WIDTH(DATA_WIDTH), .DEPTH(DATA_DEPTH)) data_mem = new;









endmodule : processor_tb
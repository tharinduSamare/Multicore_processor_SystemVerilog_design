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

logic rstN,start;
logic [REG_WIDTH-1:0]DataMemOut;
logic [INS_WIDTH-1:0]InsMemOut;
logic  [REG_WIDTH-1:0]dataMemAddr,DataMemIn;
logic  [INS_WIDTH-1:0]insMemAddr;
logic  DataMemWrEn;
logic  done,ready;

processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH))dut(.*);








endmodule : processor_tb
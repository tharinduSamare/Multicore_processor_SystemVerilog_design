module binaryToBCD_tb();

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

logic [25:0]binaryValue;
logic rst,start;
logic ready, done;
logic [3:0]digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0;

binaryToBCD dut(.*);

localparam LATENCY = 56*CLK_PERIOD;

initial begin
    @(posedge clk);
    rst <= 0;
    
    @(posedge clk);
    rst <= 1;
    start <= 0;
    binaryValue <= 162;

    @(posedge clk);
    start <= 1;
    
    #(LATENCY);
    @(posedge clk);
    start <= 0;
    binaryValue <= 43210;

    @(posedge clk);
    start <= 1;
    
    #(LATENCY);
    // @(posedge clk);
    // rst <= 0;

end
endmodule:binaryToBCD_tb
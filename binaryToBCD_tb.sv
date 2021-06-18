module binaryToBCD_tb();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 20;
logic clk;

initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

logic [25:0]binary_value;
logic rstN,start;
logic ready, done;
// logic [3:0]digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0;
logic [3:0]BCD_value[7:0];

binaryToBCD dut(.*);

localparam LATENCY = 56*CLK_PERIOD;

initial begin
    @(posedge clk);
    rstN <= 0;
    
    @(posedge clk);
    rstN <= 1;
    start <= 0;
    binary_value <= 162;

    @(posedge clk);
    start <= 1;
    
    #(LATENCY);
    @(posedge clk);
    start <= 0;
    binary_value <= 43210;

    @(posedge clk);
    start <= 1;
    
    @(posedge clk);
    repeat(10) begin
        #(LATENCY);
        @(posedge clk);
        start <= 0;
        void'(std::randomize(binary_value));

        @(posedge clk);
        start <= 1;
    end

    $stop;

end
endmodule:binaryToBCD_tb
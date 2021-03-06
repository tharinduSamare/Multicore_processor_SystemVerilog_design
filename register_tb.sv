module register_tb();

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

localparam WIDTH = 12;
logic [WIDTH-1:0]dataIn, dataOut;
logic rstN, wrEn;

register #(.WIDTH(WIDTH)) dut(.*);

initial begin
    @(posedge clk);
    #(CLK_PERIOD*4/5);
    rstN <= 0;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    rstN <= 1;
    dataIn <= 20;
    wrEn <= 0;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    dataIn <= 43;
    wrEn <= 1;

    repeat(10) begin
        @(posedge clk);
        #(CLK_PERIOD*4/5);
        dataIn = $random();
        wrEn = $random();
        rstN = $random();
    end
    
    repeat(2) @(posedge clk);
    $stop;
end

endmodule: register_tb
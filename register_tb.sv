module register_tb();

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

localparam WIDTH = 12;
logic [WIDTH-1:0]dataIn, dataOut;
logic rstN, wrEn;

register #(.WIDTH(WIDTH)) dut(.*);

initial begin
    @(posedge clk);
    rstN <= 0;

    @(posedge clk);
    rstN <= 1;
    dataIn <= 20;
    wrEn <= 0;

    @(posedge clk);
    dataIn <= 43;
    wrEn <= 1;

    repeat(10) begin
        @(posedge clk);
        std::randomize(dataIn);
        std::randomize(wrEn);
        std::randomize(rstN);
    end
end

endmodule: register_tb
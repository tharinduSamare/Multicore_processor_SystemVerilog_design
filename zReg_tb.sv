module zReg_tb();

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
logic [WIDTH-1:0]dataIn;
logic rstN, wrEn, Zout;

zReg #(.WIDTH(WIDTH)) dut(.*);

initial begin
    @(posedge clk);
    rstN <= 0;

    @(posedge clk);
    rstN <= 1;
    dataIn <= 0;
    wrEn <= 0;

    @(posedge clk);
    dataIn <= 0;
    wrEn <= 1;

    @(posedge clk);
    dataIn <= 4;
    wrEn <= 1;

    repeat(10) begin
        @(posedge clk);
        dataIn = $urandom();
        wrEn = $urandom();
        rstN = $urandom();
    end
    
    $stop;
end

endmodule: zReg_tb
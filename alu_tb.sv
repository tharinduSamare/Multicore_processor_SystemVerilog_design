module alu_tb();

timeunit 1ns;
timeprecision 1ps;

localparam CLK_PERIOD = 10;

logic clk;
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
end

localparam WIDTH = 12;

logic signed [WIDTH-1:0]a,b,c;
logic [2:0]selectOp;

alu #(.WIDTH(WIDTH))dut(.*);

initial begin
    @(posedge clk);
    a <= 10;
    b <= 3;
    selectOp <= 0;

    @(posedge clk);
    selectOp <= 1;

    @(posedge clk);
    selectOp <= 2;

    @(posedge clk);
    selectOp <= 3;

    @(posedge clk);
    selectOp <= 4;

    @(posedge clk);
    selectOp <= 5;

    @(posedge clk);
    selectOp <= 6;

    @(posedge clk);
    a <= 20;
    b <= -30;
    selectOp <= 0;

    @(posedge clk);
    selectOp <= 1;

    @(posedge clk);
    selectOp <= 2;

    @(posedge clk);
    selectOp <= 3;

    @(posedge clk);
    selectOp <= 4;

    @(posedge clk);
    selectOp <= 5;

    @(posedge clk);
    selectOp <= 6;

    repeat(10) begin
        @(posedge clk);
        std::randomize(a) ;
        std::randomize(b);
        std::randomize(selectOp);
    end
end
endmodule:alu_tb
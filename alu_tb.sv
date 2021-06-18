module alu_tb import details::*;();

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
alu_op_t selectOp;

alu #(.WIDTH(WIDTH))dut(.*);

initial begin
    @(posedge clk);
    a <= 10;
    b <= 3;
    selectOp <= clr_alu;

    @(posedge clk);
    selectOp <= pass_alu;

    @(posedge clk);
    selectOp <= add_alu;

    @(posedge clk);
    selectOp <= sub_alu;

    @(posedge clk);
    selectOp <= mul_alu;

    @(posedge clk);
    selectOp <= inc_alu;

    @(posedge clk);
    selectOp <= idle_alu;

    @(posedge clk);
    a <= 20;
    b <= -30;
    selectOp <= clr_alu;

    @(posedge clk);
    selectOp <= pass_alu;

    @(posedge clk);
    selectOp <= add_alu;

    @(posedge clk);
    selectOp <= sub_alu;

    @(posedge clk);
    selectOp <= mul_alu;

    @(posedge clk);
    selectOp <= inc_alu;

    @(posedge clk);
    selectOp <= idle_alu;

    @(posedge clk);
    repeat(10) begin
        @(posedge clk);
        void'(std::randomize(a)) ;
        void'(std::randomize(b));
        void'(std::randomize(selectOp));
    end
    $stop;
end
endmodule:alu_tb
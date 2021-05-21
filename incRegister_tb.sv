class rand_num #(WIDTH);

    rand bit signed [WIDTH-1:0] num;
    constraint c {num inside {[-2**(WIDTH-1): 2**(WIDTH-1)-1]};}

    function new();
    this.randomize();   
    endfunction
endclass


module incRegister_tb();

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

logic unsigned [WIDTH-1:0]dataIn, dataOut;
logic wrEn, incEn, rstN;

incRegister #(.WIDTH(WIDTH)) dut(.*);

rand_num #(.WIDTH(WIDTH)) dataIn_r;

bit x;
initial begin
    @(posedge clk);
    rstN <= 0;

    @(posedge clk);
    dataIn <= 23;
    wrEn <= 1;

    @(posedge clk);
    dataIn <= 36;
    wrEn <= 1;
    rstN <= 1;

    @(posedge clk);
    dataIn <= 15;
    wrEn <= 0;
    incEn <= 1;

    repeat (10) begin
        @(posedge clk);
        dataIn_r = new();
        dataIn <= dataIn_r.num;
        // std::randomize(dataIn);
        x = std::randomize(wrEn);
        x = std::randomize(incEn);
        x = std::randomize(rstN);
    end
end

initial begin
    forever begin
       @(posedge clk);
        $display("dataIn = %d   rstN = %b    wrEn = %b   incEn = %b    dataOut = %d", dataIn, rstN, wrEn, incEn, dataOut);  
    end
    
end

endmodule:incRegister_tb
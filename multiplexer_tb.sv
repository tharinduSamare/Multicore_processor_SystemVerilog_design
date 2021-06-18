module multiplexer_tb import details::*;
();

timeunit 1ns;
timeprecision 1ps;

localparam CLK_PERIOD = 10;
logic clk;
initial begin
    clk = 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam  DMem_sel = 4'b0,
            R_sel = 4'd1,
            IR_sel = 4'd2,
            RL_sel = 4'd3,
            RC_sel = 4'd4,
            RP_sel = 4'd5,
            RQ_sel = 4'd6,
            R1_sel = 4'd7,
            AC_sel = 4'd8,
            idle = 4'd9;

localparam WIDTH = 12;
localparam IR_WIDTH = 8;

bus_in_sel_t selectIn;
logic [WIDTH-1:0]DMem, R, RL, RC, RP, RQ, R1, AC;
logic [IR_WIDTH-1:0]IR;
logic [WIDTH-1:0]busOut;

multiplexer #(.WIDTH(WIDTH), .IR_WIDTH(IR_WIDTH)) dut(.*);

assign DMem = 10;
assign R = 11;
assign RL = 12;
assign RC = 13;
assign RP = 14;
assign RQ = 15;
assign R1 = 16;
assign AC = 17;
assign IR = 18;


initial begin
    for (int i = 0; i < 10 ;i++ ) begin
        @(posedge clk);
        selectIn <= bus_in_sel_t'(i);
        $display("selectIn = %d busOut = %d", i, busOut);
    end

    repeat(10) begin
        @(posedge clk);
        void'(std::randomize(selectIn));
        $display("selectIn = %d busOut = %d", selectIn, busOut); 
    end

    $stop;
end 

endmodule:multiplexer_tb


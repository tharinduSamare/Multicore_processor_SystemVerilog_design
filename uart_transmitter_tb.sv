module uart_transmitter_tb();

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

localparam DATA_WIDTH = 8;
localparam BAUD_RATE = 19200;

logic rstN,baudTick;
logic [DATA_WIDTH-1:0]dataIn;
logic txStart;
logic tx,TxReady;

uart_baudRateGen #(.BAUD_RATE(BAUD_RATE)) baudRateGen(.*);
uart_transmitter #(.DATA_WIDTH(DATA_WIDTH)) transmitter(.*);

initial begin
    @(posedge clk);
    rstN <= 1'b0;
    @(posedge clk);
    rstN <= 1'b1;

    forever begin
        @(posedge clk);
        if (TxReady) begin
            std::randomize(dataIn);
            txStart = 1'b1;

            @(posedge clk);
            txStart = 1'b0;
        end
    end
end


endmodule:uart_transmitter_tb
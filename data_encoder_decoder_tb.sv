module data_encoder_decoder_tb();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 20;
logic clk;

initial begin
    clk <= 1'b0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam WORD_SIZE = 24;
localparam UART_WIDTH = 8;
localparam BAUD_RATE = 19200;
localparam BAUD_TIME_PERIOD = 10**9 / BAUD_RATE;
localparam WORD_2_UART_COUNT = WORD_SIZE/UART_WIDTH + ((WORD_SIZE % UART_WIDTH == 0)? 0:1);

//////// logic related to data_encoder_decoder
logic [WORD_SIZE-1:0]dataFromMem;
logic rstN,txStart;
logic txReady,rxDone;
logic [WORD_SIZE-1:0]dataToMem;
logic new_rx_data_indicate;

/////////////// logic related to uart_system
logic rxByteReady, rx_new_byte_indicate, txByteReady;
logic [UART_WIDTH-1:0] byteFromRx;
logic txByteStart;
logic [UART_WIDTH-1:0] byteForTx;
logic rx, tx;

logic tx_ready,rx_ready;

assign txByteReady = tx_ready;
assign rxByteReady = rx_ready;

data_encoder_decoder #(.WORD_SIZE(WORD_SIZE), .UART_WIDTH(UART_WIDTH)) dut(.*);

uart_system #(.DATA_WIDTH(UART_WIDTH), .BAUD_RATE(BAUD_RATE)) uart_system (.*);

initial begin

    @(posedge clk);
    rstN <= 1'b0;
    rx = 1'b1;
    txStart <= 1'b0;

    @(posedge clk);
    rstN <= 1'b1;

    //////////transmission check

    // for (int i=0;i<5;i++) begin:tx_check
    //     @(posedge clk);
    //     wait(txReady);
    //     @(posedge clk);
    //     void'(std::randomize(dataFromMem));
    //     txStart <= 1'b1;

    //     @(posedge clk);
    //     txStart <= 1'b0;
    // end

    /////////////////receiver check

    for (int j=0; j< WORD_2_UART_COUNT * 5;j++) begin:rx_check
        @(posedge clk);  //starting delimiter
        rx <= 1'b0;
        #(BAUD_TIME_PERIOD);
        for (int i=0;i<UART_WIDTH;i++) begin:data  //data
            @(posedge clk);
            void'(std::randomize(rx));
            #(BAUD_TIME_PERIOD);
        end
        @(posedge clk);  // end delimiter
        rx <= 1'b1;
        #(BAUD_TIME_PERIOD);

    end
end

endmodule:data_encoder_decoder_tb
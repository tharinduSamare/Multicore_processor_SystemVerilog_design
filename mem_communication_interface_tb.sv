class Memory #(parameter DEPTH , WIDTH);

    localparam ADDR_WIDTH = $clog2(DEPTH);
    typedef logic [WIDTH-1:0] mem_t [0:DEPTH-1]; 
    typedef logic [WIDTH-1:0]  data_t;
    typedef logic [ADDR_WIDTH-1:0] addr_t;

    rand mem_t memory;
    // addr_t addr;

    function new();
      void'(this.randomize(memory));      
    endfunction 

    function logic[WIDTH-1:0] getData(input addr_t addr);
        return this.memory[addr];
    endfunction

    function void storeData(input addr_t addr, input data_t data);
        this.memory[addr] = data;
    endfunction

    task Read_memory(input addr_t addr, output data_t value, ref logic clk);        // if needed read time delay can be added
        value = memory[addr];
    endtask

    task Write_memory(input addr_t addr, input data_t data, input logic wrEn, ref logic clk); // if needed write time delay can be added
        @(posedge clk);
        if (wrEn) begin
            memory[addr] = data;
        end
    endtask

endclass

module mem_communication_interface_tb ();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 20;
logic clk;
initial begin
    clk = 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end
localparam MEM_WORD_LENGTH = 12;
localparam MEM_DEPTH = 64;
localparam MEM_ADDR_LENGTH = $clog2(MEM_DEPTH);
localparam BAUD_RATE = 115200;
localparam UART_WIDTH = 8;
localparam BAUD_TIME_PERIOD = 10**9 / BAUD_RATE;
localparam WORD_2_UART_COUNT = MEM_WORD_LENGTH/UART_WIDTH + ((MEM_WORD_LENGTH % UART_WIDTH == 0)? 0:1);

localparam [MEM_ADDR_LENGTH-1:0]
    tx_start_addr_val = 0,
    tx_end_addr_val = {MEM_ADDR_LENGTH{1'b1}}, 
    rx_end_addr_val = {MEM_ADDR_LENGTH{1'b1}};
localparam bit toggle_addr_range_val = 1'b0;

//////////////input output with main program
logic rstN,txStartN;
logic mem_transmitted, mem_received;

/////////////////inputs outputs with memory
logic [MEM_WORD_LENGTH-1:0]dataFromMem;
logic memWrEn;
logic [MEM_ADDR_LENGTH-1:0]mem_address;
logic [MEM_WORD_LENGTH-1:0]dataToMem;

////////////////////inputs outputs with uart system
logic rxByteReady, rx_new_byte_indicate, txByteReady;
logic [UART_WIDTH-1:0] byteFromRx;
logic txByteStart;
logic [UART_WIDTH-1:0] byteForTx;

//// select start end mem addresses of tx and rx 
logic [MEM_ADDR_LENGTH-1:0]tx_start_addr_in,tx_end_addr_in,rx_end_addr_in;
logic toggle_addr_range;   // 0 - go untill the last address of the memory, 1 - consider inputted start, end addresses

//// logic belongs to uart_system
logic tx,rx; 

Memory #(.DEPTH(MEM_DEPTH), .WIDTH(MEM_WORD_LENGTH)) Memory_a;
initial begin
    Memory_a = new();
end


mem_communication_interface #(.MEM_WORD_LENGTH(MEM_WORD_LENGTH), .MEM_DEPTH(MEM_DEPTH), .MEM_ADDR_LENGTH(MEM_ADDR_LENGTH), .UART_WIDTH(UART_WIDTH)) mem_communication_interface (.*);

uart_system #(.DATA_WIDTH(UART_WIDTH), .BAUD_RATE(BAUD_RATE)) uart_system(.clk, .rstN,.txByteStart,.rx,.byteForTx,
                .tx, .tx_ready(txByteReady), .rx_ready(rxByteReady), .rx_new_byte_indicate, .byteFromRx);

////////////memory read and write
always_ff @(posedge clk) begin
    Memory_a.Read_memory(.addr(mem_address), .value(dataFromMem), .clk(clk));
end

always_ff @(posedge clk) begin
    Memory_a.Write_memory(.addr(mem_address), .data(dataToMem), .wrEn(memWrEn), .clk(clk));
end


// test transmission 
initial begin

    @(posedge clk);   // initialize values
    rstN <= 1'b0;
    rx <= 1'b1;
    txStartN <= 1'b1;
    tx_start_addr_in <= tx_start_addr_val;
    tx_end_addr_in <= tx_end_addr_val;
    rx_end_addr_in <= rx_end_addr_val;
    toggle_addr_range <= toggle_addr_range_val;

    //////// transmission testing starts here
    @(posedge clk);
    rstN <= 1'b1;
    txStartN <= 1'b0;
    @(posedge clk);
    txStartN <= 1'b1;
    wait(mem_transmitted);

    @(posedge clk);
    repeat(5) @(posedge clk);
    $display("transmission is done \n");
    ///////////////// receiver testing starts here

    @(posedge clk);
    rstN <= 1'b0;
    @(posedge clk);
    rstN <= 1'b1;

    @(posedge clk);
    for (int i=0; i <= rx_end_addr_val;i++) begin
        for (int j=0; j< WORD_2_UART_COUNT;j++) begin
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
        $display("dataToMem = %x", dataToMem);
    end
    
    $display("receiving is done \n%p",Memory_a.memory);
    
    $stop;  // end of the simulation
end

endmodule:mem_communication_interface_tb
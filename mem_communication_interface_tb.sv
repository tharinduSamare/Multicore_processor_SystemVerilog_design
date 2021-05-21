class Memory #(parameter DEPTH , WIDTH);

    typedef logic [WIDTH-1:0] mem_t [0:DEPTH-1];
    rand mem_t memory;
    localparam ADDR_LENGTH = $clog2(DEPTH);

    function new();
      void'(this.randomize(memory));      
    endfunction 

    function logic[WIDTH-1:0] getData(input logic [ADDR_LENGTH-1:0] addr);
        return this.memory[addr];
    endfunction

    function void storeData(input logic [ADDR_LENGTH-1:0] addr, input logic [WIDTH-1:0] data);
        this.memory[addr] = data;
    endfunction

endclass

module mem_communication_interface_tb ();

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

localparam MEM_WORD_LENGTH = 12;
localparam MEM_DEPTH = 8;
localparam MEM_ADDR_LENGTH = $clog2(MEM_DEPTH);
localparam BAUD_RATE = 19200;
localparam UART_WIDTH = 8;

//////////////input output with main program
logic rstN,txStartN;
logic  mem_transmitted, mem_received;

/////////////////inputs outputs with memory
logic [MEM_WORD_LENGTH-1:0]dataFromMem;
logic memWrEn;
logic [MEM_ADDR_LENGTH-1:0]mem_address;
logic [MEM_WORD_LENGTH-1:0]dataToMem;

////////////////////inputs outputs with uart system
logic rx, tx;

Memory #(.DEPTH(MEM_DEPTH), .WIDTH(MEM_WORD_LENGTH)) Memory_a;
initial begin
    Memory_a = new();
end


mem_communication_interface #(.MEM_WORD_LENGTH(MEM_WORD_LENGTH), .MEM_DEPTH(MEM_DEPTH), .BAUD_RATE(BAUD_RATE), .UART_WIDTH(UART_WIDTH)) mem_communication_interface (.*);

////////////memory read and write
localparam MEM_READ_DELAY = CLK_PERIOD*1;
localparam MEM_WRITE_DELAY = CLK_PERIOD*1;

initial begin
    forever begin
        if(memWrEn) begin
            #(MEM_WRITE_DELAY);
            @(posedge clk);
            Memory_a.memory[mem_address] <= dataToMem;
        end

        else begin
            #(MEM_READ_DELAY);
            @(posedge clk);
            dataFromMem = Memory_a.memory[mem_address];
        end 
    end    
end

///////////////// transmission testing starts here
// initial begin
//     @(posedge clk);
//     rstN <= 1'b0;
//     rx <= 1'b1;
//     txStartN <= 1'b1;

//     @(posedge clk);
//     rstN <= 1'b1;
//     txStartN <= 1'b0;

//     @(posedge clk);
//     txStartN <= 1'b1;

//     wait(mem_transmitted);
//     $display("transmission is done mem_depth = %d",MEM_DEPTH );
// end

///////////////// receiver testing starts here
localparam UART_DATA_WIDTH = 8;
localparam BAUD_RATE = 19200;
localparam BAUD_TIME_PERIOD = 10**9 / BAUD_RATE;
localparam WORD_2_UART_COUNT = MEM_WORD_LENGTH/UART_DATA_WIDTH + ((MEM_WORD_LENGTH % UART_DATA_WIDTH == 0)? 0:1);

initial begin
///////////////// transmission testing starts here
    @(posedge clk);
    rstN <= 1'b0;
    rx <= 1'b1;
    txStartN <= 1'b1;

    @(posedge clk);
    rstN <= 1'b1;
    txStartN <= 1'b0;

    @(posedge clk);
    txStartN <= 1'b1;

    wait(mem_transmitted);
    $display("transmission is done mem_depth = %d",MEM_DEPTH );

    // @(posedge clk);
    // rstN <= 1'b0;
    // rx <= 1'b1;
    // @(posedge clk);
    // rstN <= 1'b1;

///////////////// receiver testing starts here
    for (int j=0; j< WORD_2_UART_COUNT * MEM_DEPTH;j++) begin:rx_check
        @(posedge clk);  //starting delimiter
        rx <= 1'b0;
        #(BAUD_TIME_PERIOD);
        for (int i=0;i<UART_DATA_WIDTH;i++) begin:data  //data
            @(posedge clk);
            void'(std::randomize(rx));
            #(BAUD_TIME_PERIOD);
        end
        @(posedge clk);  // end delimiter
        rx <= 1'b1;
        #(BAUD_TIME_PERIOD);
        $display("dataToMem = %x", dataToMem);
    end
    $display("transmission is done/n memory = %p",Memory_a.memory);
end

endmodule:mem_communication_interface_tb
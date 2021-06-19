module toFpga (
    input logic CLOCK_50,
    input logic [1:0]KEY,
    output logic [1:0]LEDG,
    output logic [6:0]HEX0,HEX1,HEX2, HEX3, HEX4,HEX5, HEX6, HEX7,  // for checking perposes
    input logic UART_RXD,
	output logic UART_TXD
);

localparam CORE_COUNT = 1;
localparam REG_WIDTH = 12;
localparam DATA_MEM_WIDTH = CORE_COUNT * REG_WIDTH;
localparam INS_WIDTH = 8;
localparam INS_MEM_DEPTH = 256;
localparam DATA_MEM_DEPTH = 4096;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);
localparam INS_MEM_ADDR_WIDTH = $clog2(INS_MEM_DEPTH);

localparam BAUD_RATE = 115200;
localparam UART_WIDTH = 8;

////// logic related to data memory //////////
logic [DATA_MEM_WIDTH-1:0]DataMemOut, DataMemIn, processor_DataOut, uart_DataOut;
logic [DATA_MEM_ADDR_WIDTH-1:0] processor_dataMemAddr;
logic [DATA_MEM_ADDR_WIDTH-1:0] dataMemAddr, uart_dataMemAddr;

////// logic related to instruction memory ///////////
logic [INS_WIDTH-1:0]InsMemOut, InsMemIn;
logic [INS_MEM_ADDR_WIDTH-1:0] processor_InsMemAddr; 
logic [INS_MEM_ADDR_WIDTH-1:0]insMemAddr,uart_InsMemAddr;

////// other logics ////////////
logic dataMemWrEn, processor_DataMemWrEn, uart_dataMemWrEn;
logic uart_InsMemWrEn;
logic clk, rstN, startN, processStart;
logic processDone, processor_ready; 

/// logic related to communication unit //////////////
logic rxByteReady, txByteReady;
logic rx_new_byte_indicate, new_ins_byte_indicate, new_data_byte_indicate;
logic txByteStart;

logic [7:0]byteForTx, byteFromRx;

logic uart_DataMem_transmitted, uart_DataMem_received, uart_InsMem_received;
logic uart_dmem_start_transmitN;
//////////////////////////////////////
assign LEDG[1] = processDone;
assign LEDG[0] = processor_ready;



///////////////// state change logic

typedef enum logic [2:0] {
    idle = 3'd0,
    uart_receive_Imem = 3'd1,
    uart_receive_dmem = 3'd2,
    process_ready = 3'd3,
    process_exicute = 3'd4,
    uart_transmit_dmem = 3'd5,
    finish = 3'd6
} state_t;

state_t currentState, nextState; 

always @(posedge clk) begin
    if (~rstN) begin
        currentState <= idle;
    end
    else begin
        currentState <= nextState;
    end
end

always_comb begin
    nextState = currentState;

    case (currentState)
        idle: begin     // start state
            if (~startN) begin
                nextState = uart_receive_Imem;
            end
        end

        uart_receive_Imem: begin  // send the instructions (machine_code) from PC through UART
            if (uart_InsMem_received) begin
                nextState = uart_receive_dmem;
            end
        end
    
        uart_receive_dmem: begin  //send the data memory values from PC through UART
            if (uart_DataMem_received) begin
                nextState = process_exicute;
            end
        end

        process_exicute: begin  // processor exicute program (matrix multiplication)
            if (processDone) begin
                nextState = uart_transmit_dmem;
            end
        end

        uart_transmit_dmem: begin   // send the answer matrix to PC through UART
            if (uart_DataMem_transmitted) begin
                nextState = finish;
            end
        end

        finish: begin  //End of the process
            
        end

        default : nextState = idle;            
        
    endcase
end

assign clk = CLOCK_50;
assign rstN = KEY[0];
assign startN = KEY[1];
assign processStart = ((currentState == uart_receive_dmem) && (uart_DataMem_received))? 1'b1: 1'b0;
assign uart_dmem_start_transmitN = ((currentState == process_exicute) && (processDone))? 1'b0: 1'b1;

assign dataMemWrEn = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_dataMemWrEn:
                    (currentState == process_exicute)? processor_DataMemWrEn:
                    1'b0;

assign dataMemAddr = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_dataMemAddr:
                    (currentState == process_exicute)? processor_dataMemAddr:
                    {DATA_MEM_ADDR_WIDTH{1'b0}};

assign DataMemIn = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_DataOut:
                    (currentState == process_exicute)? processor_DataOut:
                    {DATA_MEM_WIDTH{1'b0}};

assign insMemAddr = (currentState == uart_receive_Imem)? uart_InsMemAddr:
                    (currentState == process_exicute)? processor_InsMemAddr:
                    {INS_MEM_ADDR_WIDTH{1'b0}};

assign new_ins_byte_indicate = (currentState == uart_receive_Imem)? rx_new_byte_indicate: 1'b0;
assign new_data_byte_indicate = (currentState == uart_receive_dmem)? rx_new_byte_indicate: 1'b0;


////////////////////////////////////////////////////////////////////////
multi_core_processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH), .CORE_COUNT(CORE_COUNT), .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), .INS_MEM_ADDR_WIDTH(INS_MEM_ADDR_WIDTH))
                    multi_core_processor(.clk,.rstN,.start(processStart), .ProcessorDataIn(DataMemOut), .InsMemOut, 
                    .ProcessorDataOut(processor_DataOut), .insMemAddr(processor_InsMemAddr), .dataMemAddr(processor_dataMemAddr),
                    .DataMemWrEn(processor_DataMemWrEn), .done(processDone), .ready(processor_ready));


 RAM #(.WIDTH(INS_WIDTH), .DEPTH(INS_MEM_DEPTH)) IM(.clk(CLOCK_50), .wrEn(uart_InsMemWrEn), .dataIn(InsMemIn), .addr(insMemAddr), .dataOut(InsMemOut));

 RAM #(.WIDTH(DATA_MEM_WIDTH), .DEPTH(DATA_MEM_DEPTH)) DM(.clk(CLOCK_50), .wrEn(dataMemWrEn), .dataIn(DataMemIn), .addr(dataMemAddr), 
             .dataOut(DataMemOut));

// IP_insMem IP_IM(.address(insMemAddr), .clock(CLOCK_50), .data(InsMemIn), .wren(uart_InsMemWrEn), .q(InsMemOut));

// IP_dataMem IP_DM(.address(dataMemAddr), .clock(CLOCK_50), .data(DataMemIn), .wren(dataMemWrEn), 
//                .q(DataMemOut));
///////////// communication system

mem_communication_interface #(.MEM_WORD_LENGTH(DATA_MEM_WIDTH), .MEM_DEPTH(DATA_MEM_DEPTH), .UART_WIDTH(UART_WIDTH)) dMem_com_interface
            (
                .clk, .rstN, .txStartN(uart_dmem_start_transmitN),
                .mem_transmitted(uart_DataMem_transmitted), .mem_received(uart_DataMem_received),
                /////inputs outputs with memory
                .dataFromMem(DataMemOut), .memWrEn(uart_dataMemWrEn) , .mem_address(uart_dataMemAddr), .dataToMem(uart_DataOut),
                ////////inputs outputs with uart system
                .rxByteReady, .rx_new_byte_indicate(new_data_byte_indicate), .txByteReady, 
                .byteFromRx, .txByteStart, .byteForTx,
                ///////// select start end mem addresses of tx and rx 
                .tx_start_addr_in(uartMemory[1]), .tx_end_addr_in(uartMemory[2]), 
                .rx_end_addr_in(uartMemory[0]), .toggle_addr_range(1'b1)
            );

mem_communication_interface #(.MEM_WORD_LENGTH(INS_WIDTH), .MEM_DEPTH(INS_MEM_DEPTH), .UART_WIDTH(UART_WIDTH)) insMem_com_interface
            (
                .clk, .rstN, .txStartN(1'b1),
                .mem_transmitted(), .mem_received(uart_InsMem_received),
                /////inputs outputs with memory
                .dataFromMem(), .memWrEn(uart_InsMemWrEn), .mem_address(uart_InsMemAddr), .dataToMem(InsMemIn),
                ////////inputs outputs with uart system
                .rxByteReady, .rx_new_byte_indicate(new_ins_byte_indicate), .txByteReady, .byteFromRx, .txByteStart(), .byteForTx(),

                ////////// //select start end mem addresses of tx and rx 
                .tx_start_addr_in(), .tx_end_addr_in(), .rx_end_addr_in(),
                .toggle_addr_range(1'b0)
            );

uart_system #(.DATA_WIDTH(UART_WIDTH), .BAUD_RATE(BAUD_RATE)) uart_system (
    .clk, .rstN,.txByteStart,.rx(UART_RXD), .byteForTx, .tx(UART_TXD), .tx_ready(txByteReady), .rx_ready(rxByteReady), .rx_new_byte_indicate, 
    .byteFromRx
);

//////////// memory addesses identification to find end of receiving dataMem and answer matrix transmission start & end addresses
localparam  Q_end_addr_location = DATA_MEM_ADDR_WIDTH'(12'd7),
            R_start_addr_location = DATA_MEM_ADDR_WIDTH'(12'd5),
            R_end_addr_location = DATA_MEM_ADDR_WIDTH'(12'd8);

logic [REG_WIDTH-1:0]uartMemory[2:0]; //0- end address of Q, 1- start address of R, 2- end address of R

always_ff @(posedge clk) begin
    if (~rstN) begin
        uartMemory <= '{default:'0};
    end
    else if (uart_dataMemWrEn & (currentState == uart_receive_dmem)) begin
        if (uart_dataMemAddr == Q_end_addr_location)
            uartMemory[0] <= uart_DataOut[REG_WIDTH-1:0];
        else if (uart_dataMemAddr == R_start_addr_location)
            uartMemory[1] <= uart_DataOut[REG_WIDTH-1:0];
        else if (uart_dataMemAddr == R_end_addr_location)
            uartMemory[2] <= uart_DataOut[REG_WIDTH-1:0];
    end
end

//////////////to count the time taken to the process
logic [25:0]currentTime;
timeCounter TC(.clk(CLOCK_50), .rstN(rstN), .start(processStart), .stop(processDone), 
                .timeDuration(currentTime));

logic [6:0]hex_display_value[7:0];
assign '{HEX7,HEX6,HEX5, HEX4, HEX3,HEX2, HEX1, HEX0} = hex_display_value;

hex_display HD(.clk, .rstN, .state(currentState), 
            .start_timeValue_convetion(~uart_DataMem_transmitted), .binary_time_value(currentTime), 
            .hex_display_value
            );

endmodule :toFpga


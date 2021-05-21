module data_encoder_decoder 
#(
    parameter WORD_SIZE = 12, // width of memory word
    parameter UART_WIDTH = 8
)
(
    input  logic [WORD_SIZE-1:0]dataFromMem,
    input  logic clk,rstN,txStart,
    output logic txReady,rxDone,
    output logic [WORD_SIZE-1:0]dataToMem,
    output logic new_rx_data_indicate,

    //////////// uart ports
    input logic rxByteReady, rx_new_byte_indicate, txByteReady,
    input logic [UART_WIDTH-1:0] byteFromRx,
    output logic txByteStart, 
    output logic [UART_WIDTH-1:0] byteForTx


); 

localparam EXTRA = ((WORD_SIZE % UART_WIDTH) == 0)?0:1;
localparam COUNT = (WORD_SIZE/UART_WIDTH) + EXTRA;
localparam BUFFER_WIDTH = COUNT * UART_WIDTH;
localparam COUNTER_LENGTH = (COUNT == 1)? 1:$clog2(COUNT);

typedef enum logic [2:0]{
    idle = 3'd0,
    transmit_1,
    transmit_2,
    receive_0 ,
    receive_1 ,
    receive_2 ,
    receive_3 
}state_t;


state_t currentState, nextState;
logic [BUFFER_WIDTH-1:0]currentTxBuffer, nextTxBuffer;
logic [BUFFER_WIDTH-1:0]currentRxBuffer, nextRxBuffer;
logic [COUNTER_LENGTH-1:0]currentTxCount, nextTxCount;
logic [COUNTER_LENGTH-1:0]currentRxCount, nextRxCount;

always_ff @(posedge clk) begin
    if (!rstN) begin
        currentTxBuffer <= '0;
        currentRxBuffer <= '0;
        currentTxCount <= '0;
        currentRxCount <= '0;
        currentState <= idle;
    end
    else begin
        currentTxBuffer <= nextTxBuffer;
        currentRxBuffer <= nextRxBuffer;
        currentTxCount <= nextTxCount;
        currentRxCount <= nextRxCount;
        currentState <= nextState;        
    end
end

always_comb begin
    nextState = currentState;
    nextTxCount = currentTxCount;
    nextRxCount = currentRxCount;
    nextTxBuffer = currentTxBuffer;
    nextRxBuffer = currentRxBuffer;

    case (currentState)
        idle: begin
            nextTxCount = '0;
            nextRxCount = '0;
            if (rx_new_byte_indicate) begin  //receiver indicates a arrival of new byte
                nextState = receive_1;
                nextRxBuffer = '0;
            end
            else if (txStart) begin
                nextState = transmit_1;
                if ((WORD_SIZE % UART_WIDTH) == 0)
                    nextTxBuffer = dataFromMem;
                else
                    nextTxBuffer = {'0,dataFromMem};
            end
        end

        transmit_1: begin           //start byte transmission
            nextState = transmit_2;
        end


        transmit_2: begin           // end of the byte transmission
            if (txByteReady) begin
                if (BUFFER_WIDTH == UART_WIDTH) begin
                    nextState = idle;
                end    
                else begin
                    nextTxCount = currentTxCount + COUNTER_LENGTH'(1'b1);
                    if (currentTxCount == COUNT-1 )   
                        nextState = idle;
                    else begin
                        nextTxBuffer = currentTxBuffer >> UART_WIDTH;
                        nextState = transmit_1;
                    end
                end
            end
        end

        receive_0: begin           // to give a EXTRA time to make rxByteReady to become 1'b0
            nextState = receive_1;
        end

        receive_1 : begin
            if(rxByteReady) begin
                if (BUFFER_WIDTH == UART_WIDTH) begin
                    nextRxBuffer = byteFromRx;
                    nextState = idle;
                end
                else begin
                    nextRxCount = currentRxCount + COUNTER_LENGTH'(1'b1);
                    nextRxBuffer = {byteFromRx,currentRxBuffer[BUFFER_WIDTH-1 -: (BUFFER_WIDTH - UART_WIDTH)]};
                    if (currentRxCount == (COUNT-1))
                        nextState = idle;
                    else
                        nextState = receive_2;
                end                
            end
        end

        receive_2: begin
            if(rx_new_byte_indicate)  //receiver indicates a arrival of new byte
                nextState = receive_3;
        end
		  
        receive_3: begin              // to give a EXTRA time to make rxByteReady to become 1'b0
            nextState = receive_1;
        end
        
    endcase
end


assign txByteStart = (currentState == transmit_1)? 1'b1: 1'b0;
assign txReady = (currentState == idle)? 1'b1 : 1'b0;
assign byteForTx = currentTxBuffer[UART_WIDTH-1:0];
assign rxDone = ((currentState == receive_1) && (rxByteReady == 1'b1) && (currentRxCount == COUNT-1 ))? 1'b1 : 1'b0;
assign dataToMem = currentRxBuffer[WORD_SIZE-1:0];
assign new_rx_data_indicate = ((currentState == idle) && (rx_new_byte_indicate))? 1'b1: 1'b0; //arrival of new data set

endmodule //data_encoder_decoder

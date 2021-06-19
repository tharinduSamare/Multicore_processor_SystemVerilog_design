module mem_communication_interface 
#(
    parameter MEM_WORD_LENGTH = 12,
    parameter MEM_DEPTH = 4096,
    parameter MEM_ADDR_LENGTH = $clog2(MEM_DEPTH),
    parameter UART_WIDTH = 8
)
 (
     //////////////input output with main program
    input  logic clk,rstN,txStartN,
    output logic  mem_transmitted, mem_received,
  
    /////////////////inputs outputs with memory
    input  logic [MEM_WORD_LENGTH-1:0]dataFromMem,
    output logic memWrEn,
    output logic [MEM_ADDR_LENGTH-1:0]mem_address,
    output logic [MEM_WORD_LENGTH-1:0]dataToMem,
    
    ////////////////////inputs outputs with uart system
    input logic rxByteReady, rx_new_byte_indicate, txByteReady,
    input logic [UART_WIDTH-1:0] byteFromRx,
    output logic txByteStart, 
    output logic [UART_WIDTH-1:0] byteForTx,

    ////////// select start end mem addresses of tx and rx 
    input logic [MEM_ADDR_LENGTH-1:0]tx_start_addr_in,tx_end_addr_in,rx_end_addr_in,
    input logic toggle_addr_range   // 0 - go untill the last address of the memory, 1 - consider inputted start, end addresses
);

localparam logic [MEM_ADDR_LENGTH-1:0] LAST_MEM_ADDR = '1; //all bits = 1

logic startTranmit,txReady,rxDone;
logic new_rx_data_indicate;

typedef enum logic [3:0] {
    idle       = 4'b0,
    transmit_0 = 4'd1,
    transmit_1 = 4'd2,
    transmit_2 = 4'd3,
    transmit_3 = 4'd4,
    receive_0  = 4'd5,
    receive_1  = 4'd6,
    receive_2  = 4'd7,
    receive_1_1= 4'd8,
    receive_1_2= 4'd9
} state_t;

state_t currentState, nextState;
logic [MEM_ADDR_LENGTH-1:0]currentAddress, nextAddress;
logic currentStartTransmit, nextStartTranmit;

logic [MEM_ADDR_LENGTH-1:0] tx_start_addr, tx_end_addr, rx_end_addr;

always_ff @(posedge clk) begin
    if (~rstN) begin
        currentState <= idle;
        currentAddress <= '0;
        currentStartTransmit <= 1'b0; 
    end
    else begin
        currentState <= nextState;
        currentAddress <= nextAddress;
        currentStartTransmit <= nextStartTranmit;
    end
end

always_comb begin
    nextState = currentState;
    nextAddress = currentAddress;
    nextStartTranmit = currentStartTransmit;

    case (currentState)
        idle: begin
            nextAddress = '0;
            nextStartTranmit = 1'b0;    //to transmit this should be zero
            if (new_rx_data_indicate)
                nextState = receive_0;
            else if (~txStartN) begin
                nextState = transmit_0;
                nextAddress = tx_start_addr;
            end
       end


        //transmission process starts here
        transmit_0: begin         // to give the address to memory
            nextState = transmit_1;
        end

        transmit_1: begin       // extra delay for ip core memory
            nextStartTranmit = 1'b1;
            nextState = transmit_2;
        end

        transmit_2: begin         // start uart transmitter
            nextStartTranmit = 1'b1;
            nextState = transmit_3;
        end

        transmit_3: begin        // find end of the uart transmission
            nextStartTranmit = 1'b0;
            if (txReady == 1'b1) begin
                if (currentAddress == tx_end_addr) begin  
                    nextState = idle;                    
                end
                else begin
                    nextAddress = currentAddress + MEM_ADDR_LENGTH'(1'b1);
                    nextState = transmit_0;
                end
            end
        end
        //receiving process starts here
        receive_0: begin            // to find the end of the uart receiving
            if (rxDone) begin
                nextState = receive_1;
            end
        end

        receive_1: begin           // store in the memory (no need extra delay as it is explicitly given in receive_0)
            nextState = receive_1_1;
        end
        
        receive_1_1: begin
            nextState = receive_1_2;
        end

        receive_1_2: begin
            nextState = receive_2;
        end

        receive_2: begin            //to find the end of the receiving process
            if (currentAddress == rx_end_addr) begin 
                nextState = idle; 
            end
            else begin
                nextAddress = currentAddress + MEM_ADDR_LENGTH'(1'b1);
                nextState = receive_0;   
            end                           
        end

    endcase
end

assign startTranmit = currentStartTransmit;
assign memWrEn = ((currentState == receive_1) || (currentState == receive_1_1))? 1'b1: 1'b0;

assign mem_address = currentAddress;

assign mem_received = ((currentState == receive_2) && (currentAddress == rx_end_addr))? 1'b1: 1'b0;
assign mem_transmitted = ((currentState == transmit_3) && (txReady == 1'b1) && (currentAddress == tx_end_addr))? 1'b1: 1'b0;

assign tx_start_addr = (toggle_addr_range == 1'b0)? '0: tx_start_addr_in;
assign tx_end_addr = (toggle_addr_range == 1'b0)? LAST_MEM_ADDR: tx_end_addr_in;

assign rx_end_addr = (toggle_addr_range == 1'b0)? LAST_MEM_ADDR:
                        (rx_end_addr_in == 0)? {{MEM_ADDR_LENGTH-4{1'b0}}, {4{1'b1}}}: //give 31 as the end rx address if input addr is small
                        rx_end_addr_in;

data_encoder_decoder #(.WORD_SIZE(MEM_WORD_LENGTH), .UART_WIDTH(UART_WIDTH)) data_encoder_decoder 
                    (
                        .dataFromMem,
                        .clk, .rstN, .txStart(startTranmit),
                        .txReady, .rxDone,
                        .dataToMem,
                        ///////////////// uart ports
                        .new_rx_data_indicate,
                        .rxByteReady, .rx_new_byte_indicate, .txByteReady,
                        .byteFromRx,
                        .txByteStart, 
                        .byteForTx
                    );

endmodule:mem_communication_interface

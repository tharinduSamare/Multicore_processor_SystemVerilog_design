module simulation_top import details::*;
(
    input logic clk, rstN, startN,
    output processor_ready, processDone
);

localparam CORE_COUNT = 2;
localparam REG_WIDTH = 12;
localparam DATA_MEM_WIDTH = CORE_COUNT * REG_WIDTH;
localparam INS_WIDTH = 8;
localparam INS_MEM_DEPTH = 256;
localparam DATA_MEM_DEPTH = 4096;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);
localparam INS_MEM_ADDR_WIDTH = $clog2(INS_MEM_DEPTH);


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
logic processStart;



///////////////// state change logic

typedef enum logic [2:0] {
    idle = 3'd0,
    process_exicute = 3'd4,
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
                nextState = process_exicute;
            end
        end

        process_exicute: begin  // processor exicute program (matrix multiplication)
            if (processDone) begin
                nextState = finish;
            end
        end


        finish: begin  //End of the process
            
        end

        default : nextState = idle;            
        
    endcase
end

assign processStart = ((currentState == idle) && (~startN))? 1'b1: 1'b0;

assign dataMemWrEn = (currentState == process_exicute)? processor_DataMemWrEn : 1'b0;

assign dataMemAddr = (currentState == process_exicute)? processor_dataMemAddr: {DATA_MEM_ADDR_WIDTH{1'b0}};

assign DataMemIn = (currentState == process_exicute)? processor_DataOut: {DATA_MEM_WIDTH{1'b0}};

assign insMemAddr = (currentState == process_exicute)? processor_InsMemAddr: {INS_MEM_ADDR_WIDTH{1'b0}};

////////////////////////////////////////////////////////////////////////
multi_core_processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH), .CORE_COUNT(CORE_COUNT), .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), .INS_MEM_ADDR_WIDTH(INS_MEM_ADDR_WIDTH))
                    multi_core_processor(.clk,.rstN,.start(processStart), .ProcessorDataIn(DataMemOut), .InsMemOut, 
                    .ProcessorDataOut(processor_DataOut), .insMemAddr(processor_InsMemAddr), .dataMemAddr(processor_dataMemAddr),
                    .DataMemWrEn(processor_DataMemWrEn), .done(processDone), .ready(processor_ready));


 INS_RAM #(.WIDTH(INS_WIDTH), .DEPTH(INS_MEM_DEPTH), .mem_init(yes)) 
        IM(.clk(clk), .wrEn(uart_InsMemWrEn), .dataIn(InsMemIn), .addr(insMemAddr), .dataOut(InsMemOut));

 DATA_RAM #(.WIDTH(DATA_MEM_WIDTH), .DEPTH(DATA_MEM_DEPTH), .mem_init(yes)) 
        DM(.clk(clk), .wrEn(dataMemWrEn), .dataIn(DataMemIn), .addr(dataMemAddr), .dataOut(DataMemOut));


endmodule :simulation_top


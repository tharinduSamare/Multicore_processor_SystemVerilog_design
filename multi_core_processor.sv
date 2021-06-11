module multi_core_processor #(
    parameter REG_WIDTH = 12,
    parameter INS_WIDTH = 8,
    parameter CORE_COUNT = 4,
)
(
    input logic clk,rstN,processStart,
    input logic [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataIn,
    input logic [INS_WIDTH-1:0]InsMemOut,
    output logic [REG_WIDTH*CORE_COUNT-1:0]processorDataOut,
)


genvar i;
generate
    for (i=0;i<CORE_COUNT; i=i+1) begin:core
        processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH)) CPU(.clk(CLOCK_50), .rstN(rstN), .start(processStart), .ProcessorDataIn(ProcessorDataIn[REG_WIDTH*i+:REG_WIDTH]), 
            .InsMemOut(InsMemOut), .dataMemAddr(processor_dataMemAddr[i]), .processor_DataOut(processorDataOut[REG_WIDTH*i+:REG_WIDTH]), 
            .insMemAddr(processor_InsMemAddr[i]), .DataMemWrEn(processor_DataMemWrEn[i]), .done(core_done[i]), .ready(core_ready[i]) ); 
    end
endgenerate

endmodule : multi_core_processor
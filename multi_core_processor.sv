module multi_core_processor #(
    parameter REG_WIDTH = 12,
    parameter INS_WIDTH = 8,
    parameter CORE_COUNT = 4,
    parameter DATA_MEM_ADDR_WIDTH = 12,
    parameter INS_MEM_ADDR_WIDTH = 8
)
(
    input logic clk,rstN,start,
    input logic [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataIn,
    input logic [INS_WIDTH-1:0]InsMemOut,
    output logic [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataOut,
    output logic [INS_MEM_ADDR_WIDTH-1:0]insMemAddr,
    output logic [DATA_MEM_ADDR_WIDTH-1:0]dataMemAddr,
    output logic DataMemWrEn, done,ready
);

logic core_DataMemWrEn[0:CORE_COUNT-1]; 
logic core_done[0:CORE_COUNT-1];
logic core_ready[0:CORE_COUNT-1];
logic [DATA_MEM_ADDR_WIDTH-1:0] core_dataMemAddr[0:CORE_COUNT-1];
logic [INS_MEM_ADDR_WIDTH-1:0] core_InsMemAddr[0:CORE_COUNT-1];

genvar i;
generate
    for (i=0;i<CORE_COUNT; i=i+1) begin:core
        processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH)) CPU(.clk, .rstN, .start, .ProcessorDataIn(ProcessorDataIn[REG_WIDTH*i+:REG_WIDTH]), 
            .InsMemOut, .dataMemAddr(core_dataMemAddr[i]), .ProcessorDataOut(ProcessorDataOut[REG_WIDTH*i+:REG_WIDTH]), 
            .insMemAddr(core_InsMemAddr[i]), .DataMemWrEn(core_DataMemWrEn[i]), .done(core_done[i]), .ready(core_ready[i]) ); 
    end
endgenerate

assign dataMemAddr = core_dataMemAddr[0];
assign DataMemWrEn = core_DataMemWrEn[0];
assign insMemAddr = core_InsMemAddr[0];
assign ready = core_ready[0];
assign done = core_done[0];

endmodule : multi_core_processor
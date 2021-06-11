module processor import details::*;
#(
    parameter REG_WIDTH = 12,
    parameter INS_WIDTH = 8
)
(
    input  logic clk,rstN,start,
    input  logic [REG_WIDTH-1:0]ProcessorDataIn,
    input  logic [INS_WIDTH-1:0]InsMemOut,
    output logic  [REG_WIDTH-1:0]dataMemAddr,ProcessorDataOut,
    output logic  [INS_WIDTH-1:0]insMemAddr,
    output logic  DataMemWrEn,
    output logic  done,ready
);

logic [REG_WIDTH-1:0]alu_a, alu_b, alu_out;
alu_op_t select_alu_op;
bus_in_sel_t busSel;
logic [REG_WIDTH-1:0]busOut;
logic [INS_WIDTH-1:0]IRout;
logic [REG_WIDTH-1:0] Rout, RLout, RCout, RPout, RQout, R1out, ACout;
logic Zout, ZWrEn;
inc_reg_t incReg;    // {PC, RC, RP, RQ}
logic PC_inc, RC_inc, RP_inc, RQ_inc;
wrEnReg_t wrEnReg;   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}
logic AR_wrEn,R_wrEn,PC_wrEn,IR_wrEn,RL_wrEn,RC_wrEn,RP_wrEn,RQ_wrEn,R1_wrEn,AC_wrEn;

assign {PC_inc, RC_inc, RP_inc, RQ_inc} = incReg;
assign {AR_wrEn,R_wrEn,PC_wrEn,IR_wrEn,RL_wrEn,RC_wrEn,RP_wrEn,RQ_wrEn,R1_wrEn,AC_wrEn} = wrEnReg;

controlUnit CU(.clk, .rstN, .start, .Zout, .instruction(ISA_t'(IRout)), .aluOp(select_alu_op), .incReg,
                .wrEnReg, .busSel, .DataMemWrEn, .ZWrEn, .done, .ready);

alu #(.WIDTH(REG_WIDTH)) alu(.a(alu_a), .b(alu_b), .selectOp(select_alu_op), .c(alu_out));

multiplexer #(.WIDTH(REG_WIDTH), .IR_WIDTH(INS_WIDTH)) mux(.selectIn(busSel), .DMem(ProcessorDataIn), .R(Rout), .RL(RLout), .RC(RCout), .RP(RPout), .RQ(RQout), .R1(R1out), 
                .AC(ACout), .IR(IRout), .busOut(busOut));

register #(.WIDTH(REG_WIDTH)) AR(.dataIn(busOut), .wrEn(AR_wrEn), .rstN(rstN), .clk(clk), .dataOut(dataMemAddr));

register #(.WIDTH(REG_WIDTH)) R(.dataIn(busOut), .wrEn(R_wrEn), .rstN(rstN), .clk(clk), .dataOut(Rout));

incRegister #(.WIDTH(INS_WIDTH)) PC(.dataIn(IRout), .wrEn(PC_wrEn), .rstN(rstN), .clk(clk), .incEn(PC_inc), .dataOut(insMemAddr));

register #(.WIDTH(INS_WIDTH)) IR(.dataIn(InsMemOut), .wrEn(IR_wrEn), .rstN(rstN), .clk(clk), .dataOut(IRout));    

register #(.WIDTH(REG_WIDTH)) RL(.dataIn(busOut), .wrEn(RL_wrEn), .rstN(rstN), .clk(clk), .dataOut(RLout));

incRegister #(.WIDTH(REG_WIDTH)) RC(.dataIn(busOut), .wrEn(RC_wrEn), .rstN(rstN), .clk(clk), .incEn(RC_inc), .dataOut(RCout));

incRegister #(.WIDTH(REG_WIDTH)) RP(.dataIn(busOut), .wrEn(RP_wrEn), .rstN(rstN), .clk(clk), .incEn(RP_inc), .dataOut(RPout));

incRegister #(.WIDTH(REG_WIDTH)) RQ(.dataIn(busOut), .wrEn(RQ_wrEn), .rstN(rstN), .clk(clk), .incEn(RQ_inc), .dataOut(RQout));

register #(.WIDTH(REG_WIDTH)) R1(.dataIn(busOut), .wrEn(R1_wrEn), .rstN(rstN), .clk(clk), .dataOut(R1out));

register #(.WIDTH(REG_WIDTH)) AC(.dataIn(alu_out), .wrEn(AC_wrEn), .rstN(rstN), .clk(clk), .dataOut(ACout));

zReg #(.WIDTH(REG_WIDTH)) Z(.dataIn(alu_out), .clk(clk), .rstN(rstN), .wrEn(ZWrEn), .Zout(Zout));

assign ProcessorDataOut = Rout;

assign alu_a = ACout;
assign alu_b = busOut;

endmodule:processor
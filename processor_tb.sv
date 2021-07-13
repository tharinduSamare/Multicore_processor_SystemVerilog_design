class RAM_class #(parameter WIDTH, DEPTH);

localparam ADDR_WIDTH = $clog2(DEPTH);

typedef logic [WIDTH-1:0]  data_t;
typedef logic [ADDR_WIDTH-1:0] addr_t;

logic [WIDTH-1:0] RAM [0:DEPTH-1];
// logic [ADDR_WIDTH-1:0] addr;


function void initialize_full_memory(input logic [WIDTH-1:0]initial_vals[0:DEPTH-1]);
    RAM = initial_vals;
endfunction

function void initialize_singal_memory_location(input data_t value, input addr_t addr);
    RAM[addr] = value;
endfunction

task Read_memory(input addr_t addr, output data_t value, ref logic clk);        // if needed read time delay can be added
    value = RAM[addr];
endtask

task Write_memory(input addr_t addr, input data_t data, input logic wrEn, ref logic clk); // if needed write time delay can be added
    @(posedge clk);
    if (wrEn) begin
        RAM[addr] = data;
    end
endtask

function void display_RAM();
    foreach(this.RAM[i])
        $display(i,this.RAM[i]);

endfunction

function data_t get_value(input addr_t addr);
    return RAM[addr];
endfunction

endclass


module processor_tb import details::*;();

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

localparam REG_WIDTH = 12;
localparam INS_WIDTH = 8;
localparam INS_MEM_DEPTH = 256;
localparam DATA_MEM_DEPTH = 4096;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);
localparam INS_MEM_ADDR_WIDTH = $clog2(INS_MEM_DEPTH);

logic rstN,start;
logic [REG_WIDTH-1:0]ProcessorDataIn;
logic [INS_WIDTH-1:0]InsMemOut;
logic  [REG_WIDTH-1:0]dataMemAddr,ProcessorDataOut;
logic  [INS_WIDTH-1:0]insMemAddr;
logic  DataMemWrEn;
logic  done,ready;

processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH), .INS_MEM_ADDR_WIDTH(INS_MEM_ADDR_WIDTH), 
            .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH))dut(.*);

///// initialize instruction and data memory /////////
RAM_class #(.WIDTH(INS_WIDTH), .DEPTH(INS_MEM_DEPTH)) ins_mem = new;
RAM_class #(.WIDTH(REG_WIDTH), .DEPTH(DATA_MEM_DEPTH)) data_mem = new;

logic [INS_WIDTH-1:0]temp_ins_mem[0:INS_MEM_DEPTH-1];
logic [REG_WIDTH-1:0]temp_data_mem[0:DATA_MEM_DEPTH-1];

initial begin
    $readmemb("D:/ACA/SEM5_TRONIC_ACA/1_EN3030 _Circuits_and_Systems_Design/2020/learnFPGA/learn_processor_design/matrix_multiply/system_verilog_design_3_1_github/Multicore_processor_matrix_multiply/matrix_generation_for_tb/9_ins_mem_tb.txt", temp_ins_mem);
    $readmemb("D:/ACA/SEM5_TRONIC_ACA/1_EN3030 _Circuits_and_Systems_Design/2020/learnFPGA/learn_processor_design/matrix_multiply/system_verilog_design_3_1_github/Multicore_processor_matrix_multiply/matrix_generation_for_tb/4_data_mem_tb.txt", temp_data_mem);
    ins_mem.initialize_full_memory(temp_ins_mem);
    data_mem.initialize_full_memory(temp_data_mem);    
end 


initial begin
    @(posedge clk);
    rstN <= 1'b0;
    start <= 1'b0;
    @(posedge clk);
    rstN <= 1'b1;
    start <= 1'b1;
end

always_ff @(posedge clk) begin
    ins_mem.Read_memory(.addr(insMemAddr), .value(InsMemOut), .clk(clk));
end

always_ff @(posedge clk) begin
    data_mem.Read_memory(.addr(dataMemAddr), .value(ProcessorDataIn), .clk(clk));
end

always_ff @(posedge clk) begin
    data_mem.Write_memory(.addr(dataMemAddr), .data(ProcessorDataOut), .wrEn(DataMemWrEn), .clk(clk));
end


////////////// verification of the simulation correctness /////////

localparam  Q_end_addr_location = DATA_MEM_ADDR_WIDTH'(12'd7),
            R_start_addr_location = DATA_MEM_ADDR_WIDTH'(12'd5),
            R_end_addr_location = DATA_MEM_ADDR_WIDTH'(12'd8);
logic [REG_WIDTH-1:0] a, b, c, P_start_addr, Q_start_addr, R_start_addr, P_end_addr, Q_end_addr, R_end_addr;

// logic [7:0]aa[0:4][0:1] = '{'{8'd1,8'd22},'{8'd33,8'd45},'{8'd53,8'd6},'{8'd1,8'd23},'{8'd11,8'd33}};
logic [REG_WIDTH-1:0] temp_data_mem_2[0:DATA_MEM_DEPTH-1];

always_ff @(posedge clk) begin
    if (done) begin
        a = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd0));
        b = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd1));
        c = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd2));
        P_start_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd3));
        Q_start_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd4));
        R_start_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd5));
        P_end_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd6));
        Q_end_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd7));
        R_end_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd8));

        
        temp_data_mem_2 = data_mem.RAM;
        $writememb("D:/ACA/SEM5_TRONIC_ACA/1_EN3030 _Circuits_and_Systems_Design/2020/learnFPGA/learn_processor_design/matrix_multiply/system_verilog_design_3_1_github/Multicore_processor_matrix_multiply/matrix_generation_for_tb/11_data_mem_out.txt", temp_data_mem_2); // write data memory content to a file
        // $writememh("../../7_multiply_answer.txt", aa);

        $display("\nMatrix P\n");
        print_matrix_P(data_mem.RAM, a,b,P_start_addr, P_end_addr);

        $display("\nMatrix Q\n");
        print_matrix_Q(data_mem.RAM,b,c,Q_start_addr,Q_end_addr);

        $display("\nMatrix R\n");
        print_matrix_R(data_mem.RAM,a,c,R_start_addr,R_end_addr);

        $stop;
    end
end

function void print_matrix_P(input logic [REG_WIDTH-1:0]DMEM[0:DATA_MEM_DEPTH-1], logic [REG_WIDTH-1:0]a,b,P_start_addr,P_end_addr);
    for (int i=P_start_addr;i<P_end_addr;i=i+b) begin
        for (int j=i;j<i+b;j++) begin
            $write("%h ", DMEM[j]);
        end
        $write("\n");
    end
endfunction

function void print_matrix_Q(input logic [REG_WIDTH-1:0]DMEM[0:DATA_MEM_DEPTH-1], logic [REG_WIDTH-1:0]b,c,Q_start_addr,Q_end_addr);
    for (int i=Q_start_addr;i<Q_start_addr+b;i++) begin
        for (int j=i;j<=Q_end_addr;j=j+b) begin
            $write("%h ", DMEM[j]);
        end
        $write("\n");
    end
endfunction

function void print_matrix_R(input logic [REG_WIDTH-1:0]DMEM[0:DATA_MEM_DEPTH-1], logic [REG_WIDTH-1:0]a,c,R_start_addr,R_end_addr);
    for (int i=R_start_addr;i<R_end_addr;i=i+c) begin
        for (int j=i;j<i+c;j++) begin
            $write("%h ", DMEM[j]);
        end
        $write("\n");
    end
endfunction 




endmodule : processor_tb
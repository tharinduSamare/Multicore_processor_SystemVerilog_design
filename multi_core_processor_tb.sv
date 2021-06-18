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


module multi_core_processor_tb import details::*;();

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

localparam CORE_COUNT = 4;
localparam REG_WIDTH = 12;
localparam INS_WIDTH = 8;
localparam INS_MEM_DEPTH = 256;
localparam DATA_MEM_DEPTH = 4096;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);
localparam INS_MEM_ADDR_WIDTH = $clog2(INS_MEM_DEPTH);
localparam DATA_MEM_WIDTH = REG_WIDTH*CORE_COUNT;

logic rstN,start;
logic [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataIn;
logic [INS_WIDTH-1:0]InsMemOut;
logic [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataOut;
logic [INS_MEM_ADDR_WIDTH-1:0]insMemAddr;
logic [DATA_MEM_ADDR_WIDTH-1:0]dataMemAddr;
logic DataMemWrEn, done,ready;

multi_core_processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH), .CORE_COUNT(CORE_COUNT), 
                        .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), .INS_MEM_ADDR_WIDTH(INS_MEM_ADDR_WIDTH))dut(.*);

///// initialize instruction and data memory /////////
RAM_class #(.WIDTH(INS_WIDTH), .DEPTH(INS_MEM_DEPTH)) ins_mem = new;
RAM_class #(.WIDTH(DATA_MEM_WIDTH), .DEPTH(DATA_MEM_DEPTH)) data_mem = new;

logic [INS_WIDTH-1:0]temp_ins_mem[0:INS_MEM_DEPTH-1];
logic [DATA_MEM_WIDTH-1:0]temp_data_mem[0:DATA_MEM_DEPTH-1];

initial begin
    $readmemb("../../9_ins_mem_tb.txt", temp_ins_mem);
    $readmemb("../../4_data_mem_tb.txt", temp_data_mem);
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

logic [DATA_MEM_WIDTH-1:0] temp_data_mem_2[0:DATA_MEM_DEPTH-1];

always_ff @(posedge clk) begin
    if (done) begin
        a = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd0))[REG_WIDTH-1:0];  
        b = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd1))[REG_WIDTH-1:0];
        c = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd2))[REG_WIDTH-1:0];
        P_start_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd3))[REG_WIDTH-1:0];
        Q_start_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd4))[REG_WIDTH-1:0];
        R_start_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd5))[REG_WIDTH-1:0];
        P_end_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd6))[REG_WIDTH-1:0];
        Q_end_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd7))[REG_WIDTH-1:0];
        R_end_addr = data_mem.get_value(DATA_MEM_ADDR_WIDTH'(12'd8))[REG_WIDTH-1:0];

        
        temp_data_mem_2 = data_mem.RAM;
        $writememh("../../7_multiply_answer.txt", temp_data_mem_2, R_start_addr,R_end_addr); // write answer matrix to a file

        $display("\nMatrix P\n");
        print_matrix_P(data_mem.RAM, a,b,P_start_addr, P_end_addr, CORE_COUNT);

        $display("\nMatrix Q\n");
        print_matrix_Q(data_mem.RAM,b,c,Q_start_addr,Q_end_addr);

        $display("\nMatrix R\n");
        print_matrix_R(data_mem.RAM,a,c,R_start_addr,R_end_addr,CORE_COUNT);

        repeat(5) @(posedge clk);  // end of the simulation
        $stop;
    end
end

function automatic void print_matrix_P(input logic [DATA_MEM_WIDTH-1:0]DMEM[0:DATA_MEM_DEPTH-1], logic [REG_WIDTH-1:0]a,b,P_start_addr,P_end_addr, int CORE_COUNT);
    int d = (a%CORE_COUNT == 0)? a/CORE_COUNT : a/CORE_COUNT+1;

    for (int x=0;x<d;x++) begin
        for (int y=CORE_COUNT;y>0;y--) begin
            if ((x+1)*CORE_COUNT-y>= a) begin
                break;
            end 
            for (int z=0;z<b;z++) begin
                logic [DATA_MEM_WIDTH-1:0]temp_1 = DMEM[(P_start_addr + x*b+z)];
                logic [REG_WIDTH-1:0]temp_2 = temp_1[(y*REG_WIDTH-1) -:REG_WIDTH];
                $write("%h ", temp_2);                
            end
            $write("\n");
        end
    end
endfunction

function automatic void print_matrix_Q(input logic [DATA_MEM_WIDTH-1:0]DMEM[0:DATA_MEM_DEPTH-1], logic [REG_WIDTH-1:0]b,c,Q_start_addr,Q_end_addr);

    for (int i=Q_start_addr;i<Q_start_addr+b;i++) begin
        for (int j=i;j<=Q_end_addr;j=j+b) begin
            logic [DATA_MEM_WIDTH-1:0] temp_1 = DMEM[j];
            $write("%h ", temp_1[REG_WIDTH-1:0]);
        end
        $write("\n");
    end
endfunction

function automatic void print_matrix_R(input logic [DATA_MEM_WIDTH-1:0]DMEM[0:DATA_MEM_DEPTH-1], logic [REG_WIDTH-1:0]a,c,R_start_addr,R_end_addr, int CORE_COUNT);
    int d = (a%CORE_COUNT == 0)? a/CORE_COUNT : a/CORE_COUNT+1;

    for (int x=0;x<d;x++) begin
        for (int y=CORE_COUNT;y>0;y--) begin
            if ((x+1)*CORE_COUNT-y>= a) begin
                break;
            end 
            for (int z=0;z<c;z++) begin
                logic [DATA_MEM_WIDTH-1:0]temp_1 = DMEM[(R_start_addr + x*c+z)];
                logic [REG_WIDTH-1:0]temp_2 = temp_1[(y*REG_WIDTH-1) -:REG_WIDTH];
                $write("%h ", temp_2);                
            end
            $write("\n");
        end
    end
endfunction


endmodule : multi_core_processor_tb


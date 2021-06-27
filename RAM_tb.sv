module RAM_tb();

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

localparam WIDTH = 12;
localparam DEPTH = 8;
localparam ADDR_WIDTH = $clog2(DEPTH);

logic wrEn;
typedef logic [WIDTH-1:0]data_t;
data_t dataIn, dataOut;
typedef logic [ADDR_WIDTH-1:0]addr_t;
addr_t addr;

RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)) dut(.*);

initial begin
    @(posedge clk);
    #(CLK_PERIOD*4/5);
    wrEn <= 1'b1;
    addr <= 3;
    dataIn <= 100;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    wrEn <= 1'b0;
    addr <= 20;
    dataIn <=30;

    repeat (20) begin
        @(posedge clk);
        #(CLK_PERIOD*4/5);    // to give data litte bit earlier to the posedge of the clk

        dataIn = $random();
        addr = $random();
        wrEn = $random();
    end    

    $stop;
end

typedef logic [WIDTH-1:0]test_memory_t[0:DEPTH-1];
test_memory_t test_memory;

function test_memory_t update (test_memory_t test_memory, logic wrEn, addr_t addr, data_t dataIn, data_t dataOut);
  
  if (wrEn) begin
      test_memory[addr] = dataIn;
  end
  
  return test_memory;
  
endfunction

function void check (test_memory_t test_memory, data_t dataOut, addr_t addr);

    if (dataOut != test_memory[addr]) begin
        $display("dataOut = %p, memory_value = %p, addr = %p", dataOut, test_memory[addr], addr);
    end
  
endfunction

initial begin
    forever begin
        @(posedge clk);
        test_memory = update (test_memory, wrEn, addr, dataIn, dataOut);

        @(negedge clk);
        #(CLK_PERIOD*1/10);
        check (test_memory, dataOut, addr);
    end
end

endmodule:RAM_tb
# Multicore_processor_matrix_multiply_SystemVerilog_design
* This is a multi-core processor design for FPGA designed using SystemVerilog language.
* In this design
  * Most of the important variables are parameterized. (Ex:- core-count of the multi-core processor, UART baudrate)
  * Every core can access only the part of the memory allocated to it.
  * Communication between laptop and FPGA happens using UART protocol.
* This is specially designed for matrix multiplication 
  * 
  * With current configurations, using single core upto 36x36 matrices can be multiplied.
* Top module (toFpga.sv) is designed for DE-115 Altera FPGA board. (To use for a different board, use appropriate input/outputs names in the top module)
* Simulation codes are given for most of the modules. (except for the time count display module) 
* Questa-sim can be used for simulations.



[Demonstration of the design](https://youtu.be/A8b6QhjnlR8)

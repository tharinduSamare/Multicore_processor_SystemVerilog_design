# Multicore_processor_matrix_multiply
* This is a multi-core processor design for FPGA
* A parameterized system-verilog design
* Mainly designed for DE-115 Altera FPGA board.
* Simulation codes are given for many codes
* Questa-sim can be used for simulations.
* This is specially designed for matrix multiplication
* In this design
  * Core-count can be changed as wished
  * Every core can access only the part of the memory allocated to it.
  * Communication happens by UART between PC and FPGA.

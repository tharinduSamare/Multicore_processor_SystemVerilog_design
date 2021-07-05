module convertToHEX(
    // input logic[4:0]in0,in1,in2,in3,in4,in5,in6,in7,
    input logic [4:0]value[7:0],
    // output logic [6:0]out0,out1,out2,out3,out4,out5,out6,out7
    output logic [6:0]Hex_value[7:0]
);

genvar i;
generate
    for (i=0;i<8;i++) begin :SSeg
        SSeg SSeg(.in(value[i]), .out(Hex_value[i]));
    end
endgenerate

endmodule :convertToHEX
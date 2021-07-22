module convertToHEX(
    input logic [4:0]value[7:0],
    output logic [6:0]Hex_value[7:0]
);

genvar i;
generate
    for (i=0;i<8;i++) begin :SSeg
        SSeg SSeg(.in(value[i]), .out(Hex_value[i]));
    end
endgenerate

endmodule :convertToHEX
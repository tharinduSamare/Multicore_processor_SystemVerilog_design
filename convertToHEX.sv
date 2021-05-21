// module convertToHEX
// (
//     input logic [3:0]in0,in1,in2,in3,in4,in5,in6,in7,
//     input logic start,rst,clk,
//     output logic  [6:0]out0,out1,out2,out3,out4,out5,out6,out7
// );

// localparam 
//     idle = 1'b0,
//     working = 1'b1;

// logic [3:0]in[0:7];
// logic [6:0]out[0:7]; 
// assign in = '{in0,in1,in2,in3,in4,in5,in6,in7};
// assign '{out0,out1,out2,out3,out4,out5,out6,out7} = out;

 
// logic currentState, nextState;

// always_ff @( posedge clk) begin 
//     if (~rst) 
//         currentState <= idle;
//     else
//         currentState <= nextState;
// end

// ///////next state logic
// always_comb begin 
//     nextState = currentState;
//     if (currentState == idle && !start)
//         nextState = working;
// end

// ////////// logic in a state

// logic on;

// always_comb begin 
//     if (currentState == idle)
//         on = 1'b0;
//     else
//         on = 1'b1;
// end

// genvar i;
// generate 
//     for ( i = 0;i<8;i++) begin : SSeg
//         SSeg SSeg(
//             .in(in[i]),
//             .out(out[i]),
//             .on(on)
//         );
//     end
// endgenerate

// endmodule:convertToHEX


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

// SSeg  s0(.in(in0),.out(out0));
// SSeg  s1(.in(in1),.out(out1));
// SSeg  s2(.in(in2),.out(out2));
// SSeg  s3(.in(in3),.out(out3));
// SSeg  s4(.in(in4),.out(out4));
// SSeg  s5(.in(in5),.out(out5));
// SSeg  s6(.in(in6),.out(out6));
// SSeg  s7(.in(in7),.out(out7));

endmodule :convertToHEX
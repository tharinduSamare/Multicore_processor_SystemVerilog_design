module binaryToBCD(
    input logic [25:0]binary_value, // to get 8 digit output need 26.57 input bits (26)
    input logic clk,rstN,start,
    output logic ready, done,
    // output logic [3:0]digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0
    output logic [3:0]BCD_value[7:0]
);

typedef enum logic [1:0] {
    idle,
    subtract,
    shift,
    over   
  } state_t;

state_t currentState,nextState;

logic [4:0]currentCount,nextCount;        //count upto 26
logic [31:0]currentValue,nextValue;
logic [25:0]currentInput,nextInput;



always @(posedge clk) begin
    if (!rstN) begin
        currentCount <= 5'b0;
        currentValue <= 32'b0;
        currentState <= idle;
        currentInput <= 26'b0;
    end else begin
        currentValue <= nextValue;
        currentCount <= nextCount;
        currentState <= nextState;
        currentInput <= nextInput;
    end
end

////next state logic
always_comb begin
    nextState = currentState;
    case (currentState) 
        idle: 
            if (!start) nextState = subtract;

        subtract: 
            nextState = shift;

        shift: 
            if (currentCount<5'd25)
                nextState = subtract;
            else
                nextState = over;

        over:
            nextState = idle;

    endcase
end

always_comb begin
    nextCount = currentCount;
    nextValue = currentValue;
    nextInput = currentInput;
    // {digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0} = 32'b0;
    BCD_value = '{default:'0};
    
    unique case (currentState)
        idle: begin
            // {digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0} = currentValue;
            for (int j=0;j<8;j++) begin :digit_set
                BCD_value[j] = currentValue[4*j+:4];
            end

            if (!start) begin        // KEY is push button stay at 1 normally
                nextCount = 5'b0;
                nextInput = binary_value;
				nextValue = 32'b0;
            end
        end

        subtract: begin
            for (int i=0;i<32;i= i+4) begin: sub
                if (currentValue[i+:4] >4)
                    nextValue[i+:4] = currentValue[i+:4] + 4'b0011;
            end          
        end

        shift: begin
            nextInput[25:1] = currentInput[24:0];
            nextValue = {currentValue[30:0],currentInput[25]};
            nextCount = currentCount+5'b1;            
        end

        over: begin
			// {digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0} = currentValue;
            for (int k=0;k<8;k++) begin :digit_set_2
                BCD_value[k] = currentValue[4*k+:4];
            end
        end   
    endcase
end

assign done = (currentState != over);  // actives the BCDtoHEX by the negedge
assign ready = (currentState == idle);

endmodule: binaryToBCD

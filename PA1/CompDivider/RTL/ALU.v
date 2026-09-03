module ALU (
    input  [31:0] src_1, src_2,
    input [1:0] funct_code,
    output reg ALU_carry,
    output reg [31:0] ALU_result
);
    always @(*) begin
        case(funct_code)
            2'b01: {ALU_carry, ALU_result}=src_1-src_2;  
            2'b10: {ALU_carry, ALU_result}=src_1+src_2;//還原
            default: {ALU_carry, ALU_result}={1'b0, src_1};
        endcase
    end
endmodule

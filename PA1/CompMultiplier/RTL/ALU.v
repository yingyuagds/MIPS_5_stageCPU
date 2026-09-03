module ALU(
    input [31:0] src_1,src_2,
    input [1:0] funct_code,
    output reg [31:0] ALU_result,
    output reg ALU_carry
);
    always@(*)
    begin
        case(funct_code)
        2'b01: {ALU_carry,ALU_result}=src_1+src_2;
        default: 
        begin
            ALU_result=src_1;
            ALU_carry=1'b0;
        end
        endcase
    end
endmodule
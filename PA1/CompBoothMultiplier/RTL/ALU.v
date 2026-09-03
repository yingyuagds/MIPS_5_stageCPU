module ALU(
    input [31:0] src_1,src_2,
    input [5:0] funct_code,
    output reg [31:0] ALU_result,
    output reg ALU_carry
);
    always@(*)
    begin
        case(funct_code)
        6'b000001: {ALU_carry,ALU_result}=src_1+src_2;
	    6'b000010: {ALU_carry,ALU_result}=src_1-src_2;
        default: 
        begin
            ALU_result=src_1;
            ALU_carry=1'b0;
        end
        endcase
    end
endmodule
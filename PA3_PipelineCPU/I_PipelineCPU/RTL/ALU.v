module ALU (
    input  wire [31:0] Src_1,     
    input  wire [31:0] Src_2,     
    input  wire [4:0]  Shamt,     
    input  wire [5:0]  Funct,     
    output reg  [31:0] ALU_result 
);
    always @(*) begin
        case (Funct)
            6'b001001: ALU_result = Src_1 + Src_2;          // Add (Addu, addiu, sw, lw)
            6'b001010: ALU_result = Src_1 - Src_2;          // Sub (Subu)
            6'b100001: ALU_result = Src_2 << Shamt;         // Sll 
            6'b100101: ALU_result = Src_1 | Src_2;          // OR 
            default:   ALU_result = 32'b0;
        endcase
    end
endmodule
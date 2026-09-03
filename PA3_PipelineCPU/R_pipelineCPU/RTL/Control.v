module Control(
    input  wire [5:0] OpCode,
    output reg        Reg_w
);
    always @(*) begin
        case(OpCode)
            6'b000000: Reg_w = 1'b1;
            default:   Reg_w = 1'b0;
        endcase
    end
endmodule
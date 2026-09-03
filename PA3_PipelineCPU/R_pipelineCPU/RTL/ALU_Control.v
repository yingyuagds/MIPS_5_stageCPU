module ALU_Control(
    input  wire [1:0] ALU_op,
    input  wire [5:0] Funct_ctrl,
    output reg  [5:0] Funct
);
    always @(*) begin
        case(ALU_op)
            2'b10: begin
                case(Funct_ctrl)
                    6'b100001: Funct = 6'b001001; // Addu 轉成 001001
                    6'b100011: Funct = 6'b001010; // Subu 轉成 001010
                    6'b000000: Funct = 6'b100001; // Sll  轉成 100001
                    6'b100101: Funct = 6'b100101; // OR   轉成 100101
                    default:   Funct = 6'b000000;
                endcase
            end
            default: Funct = 6'b000000;
        endcase
    end
endmodule
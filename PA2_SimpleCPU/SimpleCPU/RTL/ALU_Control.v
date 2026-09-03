module ALU_Control (
    input  wire [1:0] ALU_op,      
    input  wire [5:0] Funct_ctrl,  
    output reg  [5:0] Funct       
);
    always @(*) begin
        case (ALU_op)
            2'b10: begin // R-format 指令
                case (Funct_ctrl)
                    6'b100001: Funct = 6'b001001; // Addu
                    6'b100011: Funct = 6'b001010; // Subu
                    6'b000000: Funct = 6'b100001; // Sll
                    6'b100101: Funct = 6'b100101; // OR
                    default:   Funct = 6'b000000;
                endcase
            end
            2'b00: begin 
                // I-format: addiu, sw, lw (執行加法)[cite: 1]
                Funct = 6'b001001; 
            end
            2'b01: begin 
                Funct = 6'b001010; // BEQ 
            end
            2'b11: begin 
                // I-format: ori 
                Funct = 6'b100101; 
            end
            default: Funct = 6'b000000;
        endcase
    end
endmodule
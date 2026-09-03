module ALU_Control (
    input  wire [1:0] ALU_op,      // 來自 Control 模組
    input  wire [5:0] Funct_ctrl,  // 來自 Instruction[5:0]
    output reg  [5:0] Funct        // 輸出給 ALU 的控制碼
);
    always @(*) begin
        case (ALU_op)
            2'b10: begin // R-format 指令
                case (Funct_ctrl)
                    6'b100001: Funct = 6'b001001; // Addu
                    6'b100011: Funct = 6'b001010; // Subu
                    6'b000000: Funct = 6'b100001; // Sll
                    6'b100101: Funct = 6'b100101; // OR[cite: 1]
                    default:   Funct = 6'b000000;
                endcase
            end
            2'b00, 2'b01: begin 
                // I-format: addiu, sw, lw (執行加法)[cite: 1]
                Funct = 6'b001001; 
            end
            2'b11: begin 
                // I-format: ori (執行 OR)[cite: 1]
                Funct = 6'b100101; 
            end
            default: Funct = 6'b000000;
        endcase
    end
endmodule
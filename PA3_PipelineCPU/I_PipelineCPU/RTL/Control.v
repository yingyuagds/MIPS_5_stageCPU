module Control (
    input  wire [5:0] OpCode,
    output reg        Reg_dst,    // 1: Rd (R-type), 0: Rt (I-type)
    output reg        Reg_w,      
    output reg        ALU_src,    // 0: Rt_data, 1: Immediate
    output reg [1:0]  ALU_op,     
    output reg        Mem_w,      // sw
    output reg        Mem_r,      // lw
    output reg        Mem_to_reg  // 1: 來自 DM, 0: 來自 ALU
);
    always@(*)
    begin
        {Reg_dst, Reg_w, ALU_src, ALU_op, Mem_w, Mem_r, Mem_to_reg} = 8'b0;
        case(OpCode)
            6'b000000://R_format
            begin
                Reg_dst=1'b1;
                Reg_w=1'b1;
                ALU_src=0;
                ALU_op=2'b10;
                Mem_to_reg=0;
            end
            6'b001001://addi
            begin
                Reg_dst=1'b0;
                Reg_w=1'b1;
                ALU_src=1;
                ALU_op=2'b00;
                Mem_to_reg=0;
            end
            6'b100011://lw
            begin
                Reg_dst=1'b0;
                Reg_w=1'b1;
                ALU_src=1;
                ALU_op=2'b00;
                Mem_to_reg=1;
		Mem_r = 1'b1;
            end
            6'b101011://sw
            begin
                Reg_w=1'b0;
                ALU_src=1;
                ALU_op=2'b00;
                Mem_to_reg=0;
                Mem_w=1'b1;
                Mem_r=1'b0;
            end
            6'b001101://ori
            begin
                Reg_dst=1'b0;
                Reg_w=1'b1;
                ALU_src=1;
                ALU_op=2'b11;
                Mem_to_reg=0;
            end
            default: ;
        endcase
    end
endmodule
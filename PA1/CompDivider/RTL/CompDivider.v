module CompDivider (
    input         clk,rst_n,preload,start,
    input  [31:0] divisor,dividend,
    output [31:0] remainder,quotient,
    output        valid
);
    wire        start_w, preload_w;
    wire [31:0] divisor_w, dividend_w,divisor_out_w,alu_result_w;
    wire        alu_carry_w,sll_ctrl_w, wr_ctrl_w, valid_w;
    wire [1:0]funct_code_w;
    wire [63:0] remainder_w;
    wire [31:0] quotient_w;
    Interface M1 (
        .clk(clk),.rst_n(rst_n),.start(start),.preload(preload),.dividend(dividend),
        .divisor(divisor),.remainder_in(remainder_w), .quotient_in (remainder_w[31:0]),
        .valid_in(valid_w),.start_out(start_w),.preload_out(preload_w),.dividend_out(dividend_w),
        .divisor_out(divisor_w),.remainder(remainder),.quotient(quotient),.valid(valid)
    );
    Divisor M2 (
        .clk(clk),.rst_n(rst_n),.preload(preload_w),.divisor(divisor_w),.divisor_out(divisor_out_w)
    );
    Remainder M3 (
        .clk(clk),.rst_n(rst_n),.preload(preload_w),.wr_ctrl(wr_ctrl_w),.sll_ctrl(sll_ctrl_w),
        .dividend(dividend_w),.ALU_result(alu_result_w),.remainder_out(remainder_w)
    );
    ALU u_ALU (
        .src_1(remainder_w[63:32]),.src_2(divisor_out_w),.funct_code(funct_code_w),
        .ALU_carry (alu_carry_w),.ALU_result(alu_result_w)
    );
    Control u_Control (
        .clk(clk),.rst_n(rst_n),.start(start_w),.ALU_MSB(alu_carry_w),.funct_code(funct_code_w),
        .sll_ctrl(sll_ctrl_w),.wr_ctrl(wr_ctrl_w),.valid(valid_w)
    );
endmodule

module CompBoothMultiplier (
    input clk,rst_n,preload,start,
    input [31:0] multiplier,multiplicand,
    output [64:0] product,
    output valid
);
    wire start_w, preload_w;
    wire [31:0] multiplier_w,multiplicand_w,multiplicand_out_w,alu_result_w;
    wire alu_carry_w;
    wire [5:0] funct_code_w;
    wire srl_ctrl_w, wr_ctrl_w, valid_w;
    wire [64:0] product_w;
    Interface M1 (
        .clk(clk), .rst_n(rst_n),.start(start), .preload(preload),
        .multiplier(multiplier),.multiplicand(multiplicand),
        .product_in(product_w[64:1]),.valid_in(valid_w),    
        .start_out(start_w),.preload_out(preload_w),
        .multiplier_out(multiplier_w),.multiplicand_out(multiplicand_w),
        .product(product),.valid(valid)           
    );
    Multiplicand M2 (
        .clk(clk), .rst_n(rst_n),.preload(preload_w),
        .multiplicand(multiplicand_w),.multiplicand_out(multiplicand_out_w)
    );
    Product M3 (
        .clk(clk), .rst_n(rst_n),.preload(preload_w),
        .wr_ctrl(wr_ctrl_w),.srl_ctrl(srl_ctrl_w),
        .multiplier(multiplier_w),.ALU_result(alu_result_w),.product_out(product_w)
    );
    ALU M4(
        .src_1(product_w[64:33]),.src_2(multiplicand_out_w),
        .funct_code(funct_code_w),
        .ALU_result(alu_result_w),.ALU_carry(alu_carry_w)
    );
    Control M5(
        .clk(clk),.rst_n(rst_n),.start(start_w),
        .LSB(product_w[1:0]),.funct_code(funct_code_w),
        .srl_ctrl(srl_ctrl_w),.wr_ctrl(wr_ctrl_w),
        .valid(valid_w)
    );
endmodule
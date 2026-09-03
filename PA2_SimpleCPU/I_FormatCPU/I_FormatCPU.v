module I_FormatCPU (
    output wire [31:0] Output_Addr,
    output wire [31:0] mem_out,
    input  wire [31:0] Input_Addr,
    input  wire        clk, rst_n,
    input  wire        test_normal, // 0: 正常, 1: 測試
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel  // 0: IM, 1: DM
);
    wire [31:0] Instr;
    wire [31:0] Rs_data, Rt_data, Rd_data, ALU_result, Mem_r_data;
    wire [31:0] Ext_Imm;
    wire [4:0]  Write_Reg;
    wire [31:0] Src_2;
    wire [5:0]  Funct_to_ALU;

    wire Reg_dst, Reg_w, ALU_src, Mem_w, Mem_r, Mem_to_reg;
    wire [1:0] ALU_op;

    Adder PC_Adder (.Src_1(Input_Addr), .Src_2(32'd4), .Output_Addr(Output_Addr));
    IM Instruction_Mem (
        .clk(clk), .rst_n(rst_n), .Input_Addr(Input_Addr),
        .test_normal(test_normal), .ext_addr(ext_addr), .ext_data(ext_data),
        .ext_we(ext_we), .mem_sel(mem_sel), .Instr(Instr)
    );
    Control Main_Ctrl (
        .OpCode(Instr[31:26]), .Reg_dst(Reg_dst), .Reg_w(Reg_w),
        .ALU_src(ALU_src), .ALU_op(ALU_op), .Mem_w(Mem_w),
        .Mem_r(Mem_r), .Mem_to_reg(Mem_to_reg)
    );
    assign Write_Reg = Reg_dst ? Instr[15:11] : Instr[20:16];
    assign Rd_data = Mem_to_reg ? Mem_r_data : ALU_result;
    RF Register_File (
        .clk(clk), .rst_n(rst_n),.test_normal(test_normal), .Rs_addr(Instr[25:21]), .Rt_addr(Instr[20:16]),
        .Rd_addr(Write_Reg), .Rd_data(Rd_data), .Reg_w(Reg_w),
        .Rs_data(Rs_data), .Rt_data(Rt_data)
    );
    //Sign/Zero extension
    assign Ext_Imm = (Instr[31:26] == 6'b001101) ? {16'b0, Instr[15:0]} : {{16{Instr[15]}}, Instr[15:0]};
    //ALU
    assign Src_2=ALU_src?Ext_Imm:Rt_data;
    ALU_Control AC (.ALU_op(ALU_op), .Funct_ctrl(Instr[5:0]), .Funct(Funct_to_ALU));
    ALU Processor_ALU (.Src_1(Rs_data), .Src_2(Src_2), .Shamt(Instr[10:6]), .Funct(Funct_to_ALU), .ALU_result(ALU_result));
    DM Data_Mem (
        .clk(clk), .rst_n(rst_n), .test_normal(test_normal),
        .ext_addr(ext_addr), .ext_data(ext_data), .ext_we(ext_we), .mem_sel(mem_sel),
        .Mem_addr(ALU_result), .Mem_w_data(Rt_data), .Mem_w(Mem_w),
        .Mem_r_data(Mem_r_data)
    );
    assign mem_out=(test_normal)? Mem_r_data:32'b0; 
endmodule
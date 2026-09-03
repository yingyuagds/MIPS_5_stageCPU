module SimpleCPU(
    output wire [31:0] Output_Addr, // 指向 TB 的 PC_in (下一位址)
    output wire [31:0] mem_out,
    input  wire [31:0] Input_Addr,  // 來自 TB 的 PC_out (當前位址)
    input  wire        clk, rst_n,
    input  wire        test_normal, 
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel  
);
    // 線路定義
    wire [31:0] Instr;
    wire [31:0] Rs_data, Rt_data, Rd_data, ALU_result, Mem_r_data;
    wire [31:0] Ext_Imm;
    wire [4:0]  Write_Reg;
    wire [31:0] Src_2;
    wire [5:0]  Funct_to_ALU;
    wire [1:0]  ALU_op;
    wire        Zero; // 偵測 ALU 結果是否為 0

    // 控制訊號
    wire Reg_dst, Reg_w, ALU_src, Mem_w, Mem_r, Mem_to_reg;
    wire Branch, Jump; // 新增控制訊號

    // --- 位址計算路徑 (Datapath) ---
    wire [31:0] PC_plus_4;
    wire [31:0] Branch_Addr;
    wire [31:0] Jump_Addr;
    wire [31:0] Mux_Branch_Out;
    wire        PCSrc;

    // 1. 基本 PC + 4
    Adder PC_Plus4_Adder (.Src_1(Input_Addr), .Src_2(32'd4), .Output_Addr(PC_plus_4));

    // 2. 計算 Branch 位址: (PC+4) + (SignExtImm << 2)
    Adder Branch_Target_Adder (
        .Src_1(PC_plus_4), 
        .Src_2({Ext_Imm[29:0], 2'b00}), 
        .Output_Addr(Branch_Addr)
    );

    // 3. 判斷是否分支: 控制訊號為 Branch 且 ALU 比較結果相等 (Zero=1)
    assign PCSrc = Branch & Zero;
    assign Mux_Branch_Out = PCSrc ? Branch_Addr : PC_plus_4;

    // 4. 計算 Jump 位址: { (PC+4)[31:28], Instr[25:0], 2'b00 }
    assign Jump_Addr = {PC_plus_4[31:28], Instr[25:0], 2'b00};

    // 5. 最終 Output_Addr 選擇 (Jump MUX)
    assign Output_Addr = Jump ? Jump_Addr : Mux_Branch_Out;

    // --- 核心模組實例化 ---
    IM Instruction_Mem (
        .clk(clk), .rst_n(rst_n), .Input_Addr(Input_Addr),
        .test_normal(test_normal), .ext_addr(ext_addr), .ext_data(ext_data),
        .ext_we(ext_we), .mem_sel(mem_sel), .Instr(Instr)
    );

    // 注意：這裡的 Control 模組需增加 Branch 與 Jump 輸出
    Control Main_Ctrl (
        .OpCode(Instr[31:26]), 
        .Reg_dst(Reg_dst), .Reg_w(Reg_w), .ALU_src(ALU_src), 
        .ALU_op(ALU_op), .Mem_w(Mem_w), .Mem_r(Mem_r), 
        .Mem_to_reg(Mem_to_reg),
        .Branch(Branch), .Jump(Jump) // 連接新訊號
    );

    assign Write_Reg = Reg_dst ? Instr[15:11] : Instr[20:16];
    assign Rd_data = Mem_to_reg ? Mem_r_data : ALU_result;

    RF Register_File (
        .clk(clk), .rst_n(rst_n), .test_normal(test_normal), 
        .Rs_addr(Instr[25:21]), .Rt_addr(Instr[20:16]),
        .Rd_addr(Write_Reg), .Rd_data(Rd_data), .Reg_w(Reg_w),
        .Rs_data(Rs_data), .Rt_data(Rt_data)
    );

    // 擴充立即值 (I-type)[cite: 1]
    assign Ext_Imm = (Instr[31:26] == 6'b001101) ? {16'b0, Instr[15:0]} : {{16{Instr[15]}}, Instr[15:0]};

    // ALU 運算
    assign Src_2 = ALU_src ? Ext_Imm : Rt_data;
    ALU_Control AC (.ALU_op(ALU_op), .Funct_ctrl(Instr[5:0]), .Funct(Funct_to_ALU));
    
    // 注意：ALU 模組需增加 Zero 輸出以支援 BEQ[cite: 1]
    ALU Processor_ALU (
        .Src_1(Rs_data), .Src_2(Src_2), .Shamt(Instr[10:6]), 
        .Funct(Funct_to_ALU), .ALU_result(ALU_result), .Zero(Zero)
    );

    DM Data_Mem (
        .clk(clk), .rst_n(rst_n), .test_normal(test_normal),
        .ext_addr(ext_addr), .ext_data(ext_data), .ext_we(ext_we), .mem_sel(mem_sel),
        .Mem_addr(ALU_result), .Mem_w_data(Rt_data), .Mem_w(Mem_w),
        .Mem_r_data(Mem_r_data)
    );
    assign mem_out = (test_normal) ? Mem_r_data : 32'b0; 
endmodule
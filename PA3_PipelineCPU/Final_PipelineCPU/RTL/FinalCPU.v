module FinalCPU (
    output wire [31:0] mem_out,
    input  wire        clk,
    input  wire        rst_n,
    input  wire        test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel      // 0: IM, 1: DM
);
    // ===== Interface=====
    wire        i_test_normal;
    wire [31:0] i_ext_addr;
    wire [31:0] i_ext_data;
    wire        i_ext_we;
    wire        i_ext_sel;

    // ===== IF stage =====
    reg  [31:0] PC;
    wire [31:0] PC4;
    wire [31:0] Instr;
    wire [31:0] IFID_Instr;
    // ===== ID stage =====
    wire        Reg_dst, Reg_w, ALU_src, Mem_w, Mem_r, Mem_to_reg;
    wire [1:0]  ALU_op;
    wire [31:0] Rs_data, Rt_data;
    wire [31:0] Ext_Imm;
    // ===== ID/EX 輸出 =====
    wire        IDEX_Reg_w;
    wire        IDEX_Reg_dst;
    wire        IDEX_ALU_src;
    wire [1:0]  IDEX_ALU_op;
    wire        IDEX_Mem_w;
    wire        IDEX_Mem_r;
    wire        IDEX_Mem_to_reg;
    wire [31:0] IDEX_Rs_data;
    wire [31:0] IDEX_Rt_data;
    wire [4:0]  IDEX_Rd_addr;     // Instr[15:11]
    wire [4:0]  IDEX_Rt_addr;     // Instr[20:16]
    wire [5:0]  IDEX_Funct_ctrl;
    wire [4:0]  IDEX_Shamt;
    wire [31:0] IDEX_Ext_Imm;
    // ===== EX stage =====
    wire [4:0]  EX_Write_Reg;     // Reg_dst mux 輸出
    wire [31:0] EX_Src_2;         // ALU_src mux 輸出
    wire [5:0]  Funct;
    wire [31:0] ALU_result;
     // ===== EX/MEM 輸出 =====
    wire        EXMEM_Reg_w;
    wire [4:0]  EXMEM_Rd_addr;
    wire [31:0] EXMEM_Rd_data;    // ALU result
    wire        EXMEM_Mem_w;
    wire        EXMEM_Mem_r;
    wire        EXMEM_Mem_to_reg;
    wire [31:0] EXMEM_Rt_data;    // sw 寫入資料
 
    // ===== MEM stage =====
    wire [31:0] Mem_r_data;
 
    // ===== MEM/WB 輸出 =====
    wire        MEMWB_Reg_w;
    wire [4:0]  MEMWB_Rd_addr;
    wire [31:0] MEMWB_Rd_data;    // ALU result
    wire        MEMWB_Mem_to_reg;
    wire [31:0] MEMWB_Mem_r_data; // DM 讀取資料
    wire [1:0] Forward_A;
    wire [1:0] Forward_B;
    // ===== WB stage =====
    wire [31:0] WB_Rd_data;       // Mem_to_reg mux 輸出
 
    // ===== PC Register =====
    always @(posedge clk) begin
        if (!rst_n)             PC <= 32'b0;
        else if (i_test_normal) PC <= 32'b0;
        else if (PC_Write==1'b1) PC <= PC4;
    end
    // ===== EX stage =====
    // Reg_dst mux
    assign EX_Write_Reg = IDEX_Reg_dst ? IDEX_Rd_addr : IDEX_Rt_addr;
    // ALU_src mux
    assign EX_Src_2     = IDEX_ALU_src ? IDEX_Ext_Imm : IDEX_Rt_data;
 
    // ===== WB stage =====
    // Mem_to_reg mux
    assign WB_Rd_data = MEMWB_Mem_to_reg ? MEMWB_Mem_r_data : MEMWB_Rd_data;
    // ===== ID stage =====
    assign Ext_Imm = (IFID_Instr[31:26] == 6'b001101) ? {16'b0, IFID_Instr[15:0]} : {{16{IFID_Instr[15]}}, IFID_Instr[15:0]};
    // ===== mem_out 直接輸出，不經 Interface 打拍 =====
    // ===== 修正：建立 MUX 線路，並交由 Interface 打拍輸出 =====
    wire [31:0] dm_out_mux;
    assign dm_out_mux = (i_test_normal) ? Mem_r_data : 32'b0;

    Interface u_Interface (
        .clk             (clk),
        .test_normal     (test_normal),
        .ext_addr        (ext_addr),
        .ext_data        (ext_data),
        .ext_we          (ext_we),
        .mem_sel         (mem_sel),
        .mem_out         (dm_out_mux),      
        .out_test_normal (i_test_normal),
        .out_ext_addr    (i_ext_addr),
        .out_ext_data    (i_ext_data),
        .out_ext_we      (i_ext_we),
        .out_mem_sel     (i_ext_sel),
        .out_mem_out     (mem_out)     
    );
    Adder u_Adder (
        .Src_1      (PC),
        .Src_2      (32'd4),
        .Output_Addr(PC4)
    );
    IM u_IM (
        .clk        (clk),
        .rst_n      (rst_n),
        .Input_Addr (PC),
        .test_normal(i_test_normal),
        .ext_addr   (i_ext_addr),
        .ext_data   (i_ext_data),
        .ext_we     (i_ext_we),
        .mem_sel    (i_ext_sel),
        .Instr      (Instr)
    );
    wire PC_Write;
    wire IF_ID_write;
    Hazard_Detection u_Hazard (
        .ID_EX_Mem_r    (IDEX_Mem_r),
        .ID_EX_Rt_addr  (IDEX_Rt_addr),
        .IF_ID_Rs_addr  (IFID_Instr[25:21]),
        .IF_ID_Rt_addr  (IFID_Instr[20:16]),
        .PC_Write       (PC_Write),
        .IF_ID_write    (IF_ID_write),
        .Control_MUX    (Control_MUX)
    );
    IF_ID u_IFID (
        .clk      (clk),
        .IF_ID_write(IF_ID_write),
        .Instr_in (Instr),
        .Instr_out(IFID_Instr)
    );
    wire Control_MUX;
    wire actual_Reg_w   = (Control_MUX) ? 1'b0 : Reg_w;
    wire actual_Mem_w   = (Control_MUX) ? 1'b0 : Mem_w;
    wire actual_Mem_r   = (Control_MUX) ? 1'b0 : Mem_r;
    wire actual_Reg_dst = (Control_MUX) ? 1'b0 : Reg_dst;
    wire actual_ALU_src = (Control_MUX) ? 1'b0 : ALU_src;
    wire [1:0] actual_ALU_op = (Control_MUX) ? 2'b00 : ALU_op;
    wire actual_Mem_to_reg = (Control_MUX) ? 1'b0 : Mem_to_reg;

    Control u_Control (
        .OpCode    (IFID_Instr[31:26]),
        .Reg_dst   (Reg_dst),
        .Reg_w     (Reg_w),
        .ALU_src   (ALU_src),
        .ALU_op    (ALU_op),
        .Mem_w     (Mem_w),
        .Mem_r     (Mem_r),
        .Mem_to_reg(Mem_to_reg)
    );
 
    RF u_RF (
        .clk        (clk),
        .rst_n      (rst_n),
        .test_normal(i_test_normal), 
        
        .Rs_addr    (IFID_Instr[25:21]),
        .Rt_addr    (IFID_Instr[20:16]),
        .Rd_addr    (MEMWB_Rd_addr),
        .Rd_data    (WB_Rd_data),
        .Reg_w      (MEMWB_Reg_w),
        .Rs_data    (Rs_data),
        .Rt_data    (Rt_data)
    );
 
    ID_EX u_IDEX (
        .clk           (clk),
        .Reg_w_in      (actual_Reg_w),
        .Rs_addr_in    (IFID_Instr[25:21]),
        .Rs_data_in    (Rs_data),
        .Rt_data_in    (Rt_data),
        .Rd_addr_in    (IFID_Instr[15:11]),
        .Funct_ctrl_in (IFID_Instr[5:0]),
        .Shamt_in      (IFID_Instr[10:6]),
        .Reg_dst_in    (actual_Reg_dst),
        .ALU_src_in    (actual_ALU_src),
        .ALU_op_in     (actual_ALU_op),
        .Mem_w_in      (actual_Mem_w),
        .Mem_r_in      (actual_Mem_r),
        .Mem_to_reg_in (actual_Mem_to_reg),
        .Ext_Imm_in    (Ext_Imm),
        .Rt_addr_in    (IFID_Instr[20:16]),
        .Reg_w_out     (IDEX_Reg_w),
        .Rs_data_out   (IDEX_Rs_data),
        .Rt_data_out   (IDEX_Rt_data),
        .Rs_addr_out   (IDEX_Rs_addr),
        .Rd_addr_out   (IDEX_Rd_addr),
        .Funct_ctrl_out(IDEX_Funct_ctrl),
        .Shamt_out     (IDEX_Shamt),
        .Reg_dst_out   (IDEX_Reg_dst),
        .ALU_src_out   (IDEX_ALU_src),
        .ALU_op_out    (IDEX_ALU_op),
        .Mem_w_out     (IDEX_Mem_w),
        .Mem_r_out     (IDEX_Mem_r),
        .Mem_to_reg_out(IDEX_Mem_to_reg),
        .Ext_Imm_out   (IDEX_Ext_Imm),
        .Rt_addr_out   (IDEX_Rt_addr)
    );
    wire [4:0] IDEX_Rs_addr;
    Forwarding_Unit u_Forwarding (
        .ID_EX_Rs_addr  (IDEX_Rs_addr), 
        .ID_EX_Rt_addr  (IDEX_Rt_addr),
        .EX_MEM_Rd_addr (EXMEM_Rd_addr),
        .EX_MEM_Reg_w   (EXMEM_Reg_w),
        .MEM_WB_Rd_addr (MEMWB_Rd_addr),
        .MEM_WB_Reg_w   (MEMWB_Reg_w),
        .Forward_A      (Forward_A),
        .Forward_B      (Forward_B)
    );
    ALU_Control u_ALU_Control (
        .ALU_op    (IDEX_ALU_op),
        .Funct_ctrl(IDEX_Funct_ctrl),
        .Funct     (Funct)
    );
    reg [31:0] alu_input_a;
    reg [31:0] alu_input_b_temp;
    wire [31:0] alu_input_b;
    always@(*) begin
        case(Forward_A)
            2'b00: alu_input_a=IDEX_Rs_data;
            2'b01: alu_input_a=WB_Rd_data;
            2'b10: alu_input_a=EXMEM_Rd_data;
            default: alu_input_a = IDEX_Rs_data;
        endcase
    end
    always@(*) begin
        case(Forward_B)
            2'b00: alu_input_b_temp=IDEX_Rt_data;
            2'b01: alu_input_b_temp=WB_Rd_data;
            2'b10: alu_input_b_temp=EXMEM_Rd_data;
            default: alu_input_b_temp= IDEX_Rt_data;
        endcase
    end
    assign alu_input_b=(IDEX_ALU_src)?IDEX_Ext_Imm:alu_input_b_temp;
    ALU u_ALU (
        .Src_1     (alu_input_a),
        .Src_2     (alu_input_b),
        .Shamt     (IDEX_Shamt),
        .Funct     (Funct),
        .ALU_result(ALU_result)
    );
    EX_MEM u_EXMEM (
        .clk           (clk),
        .Reg_w_in      (IDEX_Reg_w),
        .Rd_addr_in    (EX_Write_Reg),
        .Rd_data_in    (ALU_result),
        .Mem_w_in      (IDEX_Mem_w),
        .Mem_r_in      (IDEX_Mem_r),
        .Mem_to_reg_in (IDEX_Mem_to_reg),
        .Rt_data_in    (alu_input_b_temp),
        .Reg_w_out     (EXMEM_Reg_w),
        .Rd_addr_out   (EXMEM_Rd_addr),
        .Rd_data_out   (EXMEM_Rd_data),
        .Mem_w_out     (EXMEM_Mem_w),
        .Mem_r_out     (EXMEM_Mem_r),
        .Mem_to_reg_out(EXMEM_Mem_to_reg),
        .Rt_data_out   (EXMEM_Rt_data)
    );
    DM u_DM (
        .clk        (clk),
        .rst_n      (rst_n),
        // 以下改為 i_ 開頭的訊號
        .test_normal(i_test_normal),
        .ext_addr   (i_ext_addr),
        .ext_data   (i_ext_data),
        .ext_we     (i_ext_we),
        .mem_sel    (i_ext_sel),
        
        .Mem_addr   (EXMEM_Rd_data),
        .Mem_w_data (EXMEM_Rt_data),
        .Mem_w      (EXMEM_Mem_w),
        .Mem_r_data (Mem_r_data)
    );
    MEM_WB u_MEMWB (
        .clk           (clk),
        .Reg_w_in      (EXMEM_Reg_w),
        .Rd_addr_in    (EXMEM_Rd_addr),
        .Rd_data_in    (EXMEM_Rd_data),
        .Mem_to_reg_in (EXMEM_Mem_to_reg),
        .Mem_r_data_in (Mem_r_data),
        .Reg_w_out     (MEMWB_Reg_w),
        .Rd_addr_out   (MEMWB_Rd_addr),
        .Rd_data_out   (MEMWB_Rd_data),
        .Mem_to_reg_out(MEMWB_Mem_to_reg),
        .Mem_r_data_out(MEMWB_Mem_r_data)
    );
endmodule
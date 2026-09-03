module R_PipelineCPU (
    output wire [31:0] mem_out,
    input  wire        clk,
    input  wire        rst_n,
    input  wire        test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel
);

    // ===== Interface 輸出 =====
    wire        i_test_normal;
    wire [31:0] i_ext_addr;
    wire [31:0] i_ext_data;
    wire        i_ext_we;
    wire        i_ext_sel;
    wire [31:0] i_mem_out;

    // ===== IF stage =====
    reg  [31:0] PC;
    wire [31:0] PC4;
    wire [31:0] Instr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'b0;
        end else if (i_test_normal) begin
            PC <= 32'b0; 
        end else begin
            PC <= PC4;
        end
    end
    
    // ===== IF/ID 輸出 =====
    wire [31:0] IFID_Instr;

    // ===== ID stage =====
    wire        Reg_w;
    wire [31:0] Rs_data, Rt_data;
    // ===== ID/EX 輸出 =====
    wire        IDEX_Reg_w;
    wire [31:0] IDEX_Rs_data, IDEX_Rt_data;
    wire [4:0]  IDEX_Rd_addr;
    wire [5:0]  IDEX_Funct_ctrl;
    wire [4:0]  IDEX_Shamt;

    // ===== EX stage =====
    wire [5:0]  Funct;
    wire [31:0] Rd_data;

    // ===== EX/MEM 輸出 =====
    wire        EXMEM_Reg_w;
    wire [4:0]  EXMEM_Rd_addr;
    wire [31:0] EXMEM_Rd_data;

    // ===== MEM/WB 輸出 =====
    wire        MEMWB_Reg_w;
    wire [4:0]  MEMWB_Rd_addr;
    wire [31:0] MEMWB_Rd_data;

    // ===== RF 輸出 =====
    wire [31:0] rf_out;
    // ===== Module Instantiation =====
    Interface u_Interface (
        .clk          (clk),
        .test_normal  (test_normal),
        .ext_addr     (ext_addr),
        .ext_data     (ext_data),
        .ext_we       (ext_we),
        .mem_sel      (mem_sel),
        .mem_out      (i_mem_out),
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

    IF_ID u_IFID (
        .clk      (clk),
        .Instr_in (Instr),
        .Instr_out(IFID_Instr)
    );

    Control u_Control (
        .OpCode(IFID_Instr[31:26]),
        .Reg_w (Reg_w)
    );

    RF u_RF (
        .clk        (clk),
        .rst_n      (rst_n),
        .Rs_addr    (IFID_Instr[25:21]),
        .Rt_addr    (IFID_Instr[20:16]),
        .Rd_addr    (MEMWB_Rd_addr),
        .Rd_data    (MEMWB_Rd_data),
        .Reg_w      (MEMWB_Reg_w),
        .test_normal(i_test_normal),
        .ext_addr   (i_ext_addr),
        .ext_data   (i_ext_data),
        .ext_we     (i_ext_we),
        .mem_sel    (i_ext_sel),
        .Rs_data    (Rs_data),
        .Rt_data    (Rt_data),
        .rf_out     (rf_out)
    );

    ID_EX u_IDEX (
        .clk          (clk),
        .Reg_w_in     (Reg_w),
        .Rs_data_in   (Rs_data),
        .Rt_data_in   (Rt_data),
        .Rd_addr_in   (IFID_Instr[15:11]),
        .Funct_ctrl_in(IFID_Instr[5:0]),
        .Shamt_in     (IFID_Instr[10:6]),
        .Reg_w_out    (IDEX_Reg_w),
        .Rs_data_out  (IDEX_Rs_data),
        .Rt_data_out  (IDEX_Rt_data),
        .Rd_addr_out  (IDEX_Rd_addr),
        .Funct_ctrl_out(IDEX_Funct_ctrl),
        .Shamt_out    (IDEX_Shamt)
    );

    ALU_Control u_ALU_Control (
        .ALU_op   (2'b10),
        .Funct_ctrl(IDEX_Funct_ctrl),
        .Funct    (Funct)
    );

    ALU u_ALU (
        .Rs_data(IDEX_Rs_data),
        .Rt_data(IDEX_Rt_data),
        .Funct  (Funct),
        .Shamt  (IDEX_Shamt),
        .Rd_data(Rd_data)
    );

    EX_MEM u_EXMEM (
        .clk        (clk),
        .Reg_w_in   (IDEX_Reg_w),
        .Rd_addr_in (IDEX_Rd_addr),
        .Rd_data_in (Rd_data),
        .Reg_w_out  (EXMEM_Reg_w),
        .Rd_addr_out(EXMEM_Rd_addr),
        .Rd_data_out(EXMEM_Rd_data)
    );

    MEM_WB u_MEMWB (
        .clk        (clk),
        .Reg_w_in   (EXMEM_Reg_w),
        .Rd_addr_in (EXMEM_Rd_addr),
        .Rd_data_in (EXMEM_Rd_data),
        .Reg_w_out  (MEMWB_Reg_w),
        .Rd_addr_out(MEMWB_Rd_addr),
        .Rd_data_out(MEMWB_Rd_data)
    );

    assign i_mem_out = (i_test_normal) ? rf_out : 32'b0;
endmodule
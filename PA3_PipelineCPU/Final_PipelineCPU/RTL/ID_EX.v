module ID_EX (
    input  wire        clk,

    input  wire        Reg_w_in,
    input wire [4:0] Rs_addr_in,
    input  wire [31:0] Rs_data_in,
    input  wire [31:0] Rt_data_in,
    input  wire [4:0]  Rd_addr_in,
    input  wire [5:0]  Funct_ctrl_in,
    input  wire [4:0]  Shamt_in,

    input  wire        Reg_dst_in,
    input  wire        ALU_src_in,
    input  wire [1:0]  ALU_op_in,
    input  wire        Mem_w_in,
    input  wire        Mem_r_in,
    input  wire        Mem_to_reg_in,
    input  wire [31:0] Ext_Imm_in,
    input  wire [4:0]  Rt_addr_in, 

    output reg [4:0] Rs_addr_out,
    output reg         Reg_w_out,
    output reg  [31:0] Rs_data_out,
    output reg  [31:0] Rt_data_out,
    output reg  [4:0]  Rd_addr_out,
    output reg  [5:0]  Funct_ctrl_out,
    output reg  [4:0]  Shamt_out,
    output reg         Reg_dst_out,
    output reg         ALU_src_out,
    output reg  [1:0]  ALU_op_out,
    output reg         Mem_w_out,
    output reg         Mem_r_out,
    output reg         Mem_to_reg_out,
    output reg  [31:0] Ext_Imm_out,
    output reg  [4:0]  Rt_addr_out
);
    initial begin
        Reg_w_out = 0; Mem_w_out = 0; Mem_r_out = 0; Mem_to_reg_out = 0;
        ALU_src_out = 0; Reg_dst_out = 0; ALU_op_out = 0;
        Rs_addr_out = 0; Rt_addr_out = 0; Rd_addr_out = 0;
        Rs_data_out = 0; Rt_data_out = 0; Ext_Imm_out = 0; 
        Funct_ctrl_out = 0; Shamt_out = 0;
    end
    always @(posedge clk) begin
        Reg_w_out      <= Reg_w_in;
        Rs_data_out    <= Rs_data_in;
        Rt_data_out    <= Rt_data_in;
        Rd_addr_out    <= Rd_addr_in;
        Funct_ctrl_out <= Funct_ctrl_in;
        Shamt_out      <= Shamt_in;
        Reg_dst_out    <= Reg_dst_in;
        ALU_src_out    <= ALU_src_in;
        ALU_op_out     <= ALU_op_in;
        Mem_w_out      <= Mem_w_in;
        Mem_r_out      <= Mem_r_in;
        Mem_to_reg_out <= Mem_to_reg_in;
        Ext_Imm_out    <= Ext_Imm_in;
        Rt_addr_out    <= Rt_addr_in;
        Rs_addr_out    <=Rs_addr_in;
    end
endmodule
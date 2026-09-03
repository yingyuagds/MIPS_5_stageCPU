module EX_MEM (
    input  wire  clk,
    input  wire        Reg_w_in,
    input  wire [4:0]  Rd_addr_in,
    input  wire [31:0] Rd_data_in,
    input  wire        Mem_w_in,
    input  wire        Mem_r_in,
    input  wire        Mem_to_reg_in,
    input  wire [31:0] Rt_data_in,
    
    output reg         Reg_w_out,
    output reg  [4:0]  Rd_addr_out,
    output reg  [31:0] Rd_data_out,
    output reg         Mem_w_out,
    output reg         Mem_r_out,
    output reg         Mem_to_reg_out,
    output reg  [31:0] Rt_data_out
);
    initial begin
        Reg_w_out = 0; Mem_w_out = 0; Mem_r_out = 0; Mem_to_reg_out = 0;
        Rd_addr_out = 0; Rd_data_out = 0; Rt_data_out = 0;
    end
    always @(posedge clk) begin
        Reg_w_out   <= Reg_w_in;
        Rd_addr_out <= Rd_addr_in;
        Rd_data_out <= Rd_data_in;
        Mem_w_out      <= Mem_w_in;
        Mem_r_out      <= Mem_r_in;
        Mem_to_reg_out <= Mem_to_reg_in;
        Rt_data_out    <= Rt_data_in;
    end
endmodule
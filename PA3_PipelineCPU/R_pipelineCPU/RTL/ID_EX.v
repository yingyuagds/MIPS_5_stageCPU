module ID_EX (
    input  wire        clk,

    input  wire        Reg_w_in,
    input  wire [31:0] Rs_data_in,
    input  wire [31:0] Rt_data_in,
    input  wire [4:0]  Rd_addr_in,
    input  wire [5:0]  Funct_ctrl_in,
    input  wire [4:0]  Shamt_in,

    output reg         Reg_w_out,
    output reg  [31:0] Rs_data_out,
    output reg  [31:0] Rt_data_out,
    output reg  [4:0]  Rd_addr_out,
    output reg  [5:0]  Funct_ctrl_out,
    output reg  [4:0]  Shamt_out
);
    always @(posedge clk) begin
        Reg_w_out      <= Reg_w_in;
        Rs_data_out    <= Rs_data_in;
        Rt_data_out    <= Rt_data_in;
        Rd_addr_out    <= Rd_addr_in;
        Funct_ctrl_out <= Funct_ctrl_in;
        Shamt_out      <= Shamt_in;
    end
endmodule
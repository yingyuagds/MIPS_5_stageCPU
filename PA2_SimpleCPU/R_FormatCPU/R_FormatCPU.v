module R_FormatCPU(
    output wire [31:0] Output_Addr,
    output wire [31:0] mem_out,
    input  wire [31:0] Input_Addr,
    input  wire        clk,
    input  wire        rst_n,
    input  wire        test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel
);
    wire [31:0] Instr;
    wire [31:0] Rs_data, Rt_data, Rd_data;
    wire        Reg_w;
    wire [31:0] rf_out;
    wire [4:0]  Rs_addr_mux, Rt_addr_mux, Rd_addr_mux;
 
    assign Rs_addr_mux = (test_normal) ? ext_addr[4:0] : Instr[25:21];
    assign Rt_addr_mux = (test_normal) ? ext_addr[4:0] : Instr[20:16];
    assign Rd_addr_mux = (test_normal) ? ext_addr[4:0] : Instr[15:11];
 
    Adder u_Adder(
        .Src_1(Input_Addr),
        .Src_2(32'd4),
        .Output_Addr(Output_Addr)
    );
 
    IM u_IM(
        .clk(clk), .rst_n(rst_n), .Input_Addr(Input_Addr),
        .test_normal(test_normal), .ext_addr(ext_addr),
        .ext_data(ext_data), .ext_we(ext_we), .mem_sel(mem_sel),
        .Instr(Instr)
    );
 
    Control u_Control(
        .OpCode(Instr[31:26]), .Reg_w(Reg_w)
    );
 
    RF u_RF(
        .clk(clk), .rst_n(rst_n),
        .Rs_addr(Rs_addr_mux), .Rt_addr(Rt_addr_mux), .Rd_addr(Rd_addr_mux),
        .Rd_data(Rd_data), .Reg_w(Reg_w), .test_normal(test_normal),
        .ext_addr(ext_addr), .ext_data(ext_data), .ext_we(ext_we), .mem_sel(mem_sel),
        .Rs_data(Rs_data), .Rt_data(Rt_data), .rf_out(rf_out)
    );
 
    ALU u_ALU(
        .Rs_data(Rs_data), .Rt_data(Rt_data),
        .Funct(Instr[5:0]),      
        .Shamt(Instr[10:6]),
        .Rd_data(Rd_data)
    );
    assign mem_out = (test_normal) ? rf_out : Rd_data;
endmodule
 
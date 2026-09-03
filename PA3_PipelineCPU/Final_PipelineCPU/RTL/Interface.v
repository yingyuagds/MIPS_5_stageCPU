module Interface (
    input clk,
    input  wire test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel,
    input  wire [31:0] mem_out,

    output reg [31:0] out_mem_out,

    output reg        out_test_normal,
    output reg [31:0] out_ext_addr,
    output reg [31:0] out_ext_data,
    output reg        out_ext_we,
    output reg        out_mem_sel
);
    always@(posedge clk)
    begin
        out_test_normal<=test_normal;
        out_ext_addr<=ext_addr;
        out_ext_data<=ext_data;
        out_ext_we<=ext_we;
        out_mem_sel<=mem_sel;
        out_mem_out<=mem_out;
    end
endmodule
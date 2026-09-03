module DM (
    input  wire        clk, rst_n,
    input  wire        test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel,
    input  wire [31:0] Mem_addr,      
    input  wire [31:0] Mem_w_data,    
    input  wire        Mem_w,         
    output wire [31:0] Mem_r_data
);
    reg [7:0] mem [0:127]; // 嚴格遵守 128x8 規格
    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i <= 127; i = i+1) mem[i] <= 8'b0;
        end
        else if (test_normal && ext_we && mem_sel) begin
            mem[(ext_addr[6:0])           ] <= ext_data[31:24];
            mem[(ext_addr[6:0] + 7'd1) & 7'h7F] <= ext_data[23:16];
            mem[(ext_addr[6:0] + 7'd2) & 7'h7F] <= ext_data[15:8];
            mem[(ext_addr[6:0] + 7'd3) & 7'h7F] <= ext_data[7:0];
        end
        else if (!test_normal && Mem_w) begin
            mem[(Mem_addr[6:0])           ] <= Mem_w_data[31:24];
            mem[(Mem_addr[6:0] + 7'd1) & 7'h7F] <= Mem_w_data[23:16];
            mem[(Mem_addr[6:0] + 7'd2) & 7'h7F] <= Mem_w_data[15:8];
            mem[(Mem_addr[6:0] + 7'd3) & 7'h7F] <= Mem_w_data[7:0];
        end
    end

    assign Mem_r_data = test_normal
        ? {mem[(ext_addr[6:0])], mem[(ext_addr[6:0]+7'd1)&7'h7F], mem[(ext_addr[6:0]+7'd2)&7'h7F], mem[(ext_addr[6:0]+7'd3)&7'h7F]}
        : {mem[(Mem_addr[6:0])], mem[(Mem_addr[6:0]+7'd1)&7'h7F], mem[(Mem_addr[6:0]+7'd2)&7'h7F], mem[(Mem_addr[6:0]+7'd3)&7'h7F]};
endmodule
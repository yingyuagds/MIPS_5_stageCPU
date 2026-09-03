module IM (
    input wire clk, rst_n,
    input wire [31:0] Input_Addr,
    input wire test_normal, 
    input wire [31:0] ext_addr, 
    input wire [31:0] ext_data, 
    input wire ext_we, 
    input wire mem_sel,  
    output wire [31:0] Instr  
);
    reg [7:0] mem[0:127]; // 嚴格遵守 128x8 規格
    integer i;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0; i<=127; i=i+1) mem[i] <= 8'b0;
        end
        else if (test_normal && ext_we && !mem_sel) begin
            // 加上 & 7'h7F 防呆，保證不超過 127
            mem[(ext_addr[6:0])           ] <= ext_data[31:24];
            mem[(ext_addr[6:0] + 7'd1) & 7'h7F] <= ext_data[23:16];
            mem[(ext_addr[6:0] + 7'd2) & 7'h7F] <= ext_data[15:8];
            mem[(ext_addr[6:0] + 7'd3) & 7'h7F] <= ext_data[7:0];
        end
    end
    
    assign Instr = (!test_normal) 
        ? {mem[(Input_Addr[6:0])], mem[(Input_Addr[6:0]+7'd1)&7'h7F], mem[(Input_Addr[6:0]+7'd2)&7'h7F], mem[(Input_Addr[6:0]+7'd3)&7'h7F]}
        : {mem[(ext_addr[6:0])], mem[(ext_addr[6:0]+7'd1)&7'h7F], mem[(ext_addr[6:0]+7'd2)&7'h7F], mem[(ext_addr[6:0]+7'd3)&7'h7F]};
endmodule
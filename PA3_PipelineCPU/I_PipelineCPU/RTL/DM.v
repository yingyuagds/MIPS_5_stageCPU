module DM (
    input  wire        clk, rst_n,
    input  wire        test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel,
    input  wire [31:0] Mem_addr,      // 正常模式：ALU result
    input  wire [31:0] Mem_w_data,    // 正常模式：Rt_data
    input  wire        Mem_w,         // 正常模式：Control 給的寫入訊號
    output wire [31:0] Mem_r_data
);
    reg [7:0] mem [0:127];
    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i <= 127; i = i+1)
                mem[i] <= 8'b0;
        end
        // 測試模式：TB 載入初始資料
        else if (test_normal && ext_we && mem_sel) begin
            mem[ext_addr[6:0]]        <= ext_data[31:24];
            mem[ext_addr[6:0] + 7'd1] <= ext_data[23:16];
            mem[ext_addr[6:0] + 7'd2] <= ext_data[15:8];
            mem[ext_addr[6:0] + 7'd3] <= ext_data[7:0];
        end
        // 正常模式：CPU 執行 sw 指令
        else if (!test_normal && Mem_w) begin
            mem[Mem_addr[6:0]]        <= Mem_w_data[31:24];
            mem[Mem_addr[6:0] + 7'd1] <= Mem_w_data[23:16];
            mem[Mem_addr[6:0] + 7'd2] <= Mem_w_data[15:8];
            mem[Mem_addr[6:0] + 7'd3] <= Mem_w_data[7:0];
        end
    end

    // 測試模式讀 ext_addr（TB dump 用），正常模式讀 Mem_addr（lw 用）
    assign Mem_r_data = test_normal
        ? {mem[ext_addr[6:0]],
           mem[ext_addr[6:0] + 7'd1],
           mem[ext_addr[6:0] + 7'd2],
           mem[ext_addr[6:0] + 7'd3]}
        : {mem[Mem_addr[6:0]],
           mem[Mem_addr[6:0] + 7'd1],
           mem[Mem_addr[6:0] + 7'd2],
           mem[Mem_addr[6:0] + 7'd3]};

endmodule
module RF (
    input wire clk, rst_n,
    input wire [4:0]  Rs_addr, Rt_addr, Rd_addr,
    input wire [31:0] Rd_data,
    input wire        Reg_w,
    input wire        test_normal,
    input wire [31:0] ext_addr, ext_data,
    input wire        ext_we, mem_sel,
    output wire [31:0] Rs_data, Rt_data,
    output wire [31:0] rf_out
);
    reg [31:0] regs [0:31]; 
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0; i<=31; i=i+1)
            begin
                regs[i]<=32'b0;
            end
        end
        else if (test_normal && ext_we && mem_sel) begin
            regs[ext_addr[4:0]] <= ext_data;
        end
        else if (!test_normal && Reg_w) begin
           if (Rd_addr!= 5'b0) regs[Rd_addr]<=Rd_data;//MIPS 架構的硬體規定，$0（即 regs[0]）被設計成永遠是 0 的常數暫存器。
        end
    end
    assign Rs_data = regs[Rs_addr];
    assign Rt_data = regs[Rt_addr];
    assign rf_out = regs[ext_addr[4:0]];
endmodule
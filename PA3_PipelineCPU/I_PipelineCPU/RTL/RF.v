module RF (
    input wire clk, rst_n,
    input wire test_normal,
    input wire [4:0]  Rs_addr, Rt_addr, Rd_addr, 
    input wire [31:0] Rd_data,
    input wire        Reg_w,
    output wire [31:0] Rs_data, Rt_data
);
    reg [31:0] regs [0:31]; 
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0; i<=31; i=i+1) regs[i] <= 32'b0;
        end
        else if (!test_normal&&Reg_w && (Rd_addr != 5'b0)) begin
            regs[Rd_addr] <= Rd_data;
        end
    end
    assign Rs_data = regs[Rs_addr];
    assign Rt_data = regs[Rt_addr];
endmodule
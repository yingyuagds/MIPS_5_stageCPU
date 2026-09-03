module IM (
    input wire clk,rst_n,
    input wire [31:0] Input_Addr,
    input wire test_normal, // 0: normal operation, 1: test operation 
    input wire [31:0] ext_addr, 
    input wire [31:0] ext_data, 
    input wire ext_we, 
    input wire mem_sel,  
    output wire [31:0] Instr  
);
    reg [7:0] mem[0:127]; 
    integer i;
     always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0; i<=127; i=i+1)
                mem[i] <= 8'b0;
        end
        else if (test_normal && ext_we && !mem_sel) begin
            mem[ext_addr]   <= ext_data[31:24];
            mem[ext_addr+1] <= ext_data[23:16];
            mem[ext_addr+2] <= ext_data[15:8];
            mem[ext_addr+3] <= ext_data[7:0];
        end
    end
    assign Instr=(!test_normal)?{mem[Input_Addr],mem[Input_Addr+1],mem[Input_Addr+2],mem[Input_Addr+3]}:{mem[ext_addr],mem[ext_addr+1],mem[ext_addr+2],mem[ext_addr+3]};
endmodule
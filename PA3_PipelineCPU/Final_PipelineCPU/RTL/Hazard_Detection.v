module Hazard_Detection (
    input  wire       ID_EX_Mem_r,
    input  wire [4:0] ID_EX_Rt_addr,
    input  wire [4:0] IF_ID_Rs_addr,
    input  wire [4:0] IF_ID_Rt_addr,
    output reg        PC_Write,
    output reg        IF_ID_write,
    output reg        Control_MUX //NOP
);
    always @(*) begin
        if (ID_EX_Mem_r && ((ID_EX_Rt_addr == IF_ID_Rs_addr) || (ID_EX_Rt_addr == IF_ID_Rt_addr))) begin
            PC_Write    = 1'b0;
            IF_ID_write = 1'b0;
            Control_MUX = 1'b1; 
        end else begin
            PC_Write    = 1'b1;
            IF_ID_write = 1'b1;
            Control_MUX = 1'b0;
        end
    end
endmodule
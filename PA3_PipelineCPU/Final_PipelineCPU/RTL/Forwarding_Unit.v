module Forwarding_Unit (
    input  wire [4:0] ID_EX_Rs_addr,
    input  wire [4:0] ID_EX_Rt_addr,
    input  wire [4:0] EX_MEM_Rd_addr,
    input  wire       EX_MEM_Reg_w,
    input  wire [4:0] MEM_WB_Rd_addr,
    input  wire       MEM_WB_Reg_w,
    output reg  [1:0] Forward_A,
    output reg  [1:0] Forward_B
);
    always @(*) 
    begin
        Forward_A = 2'b00;
        Forward_B = 2'b00;
        //Forward_A
        if (EX_MEM_Reg_w && (EX_MEM_Rd_addr != 5'b0) && (EX_MEM_Rd_addr == ID_EX_Rs_addr)) begin
            Forward_A = 2'b10;
        end 
        else if (MEM_WB_Reg_w && (MEM_WB_Rd_addr != 5'b0) && 
                 !(EX_MEM_Reg_w&&(EX_MEM_Rd_addr!=5'b0)&&(EX_MEM_Rd_addr==ID_EX_Rs_addr))&&(MEM_WB_Rd_addr == ID_EX_Rs_addr)) begin
            Forward_A = 2'b01;
        end
        //Forward_B
        if (EX_MEM_Reg_w && (EX_MEM_Rd_addr != 5'b0) && (EX_MEM_Rd_addr == ID_EX_Rt_addr)) begin
            Forward_B = 2'b10;
        end 
        else if (MEM_WB_Reg_w && (MEM_WB_Rd_addr != 5'b0) && 
                 !(EX_MEM_Reg_w && (EX_MEM_Rd_addr != 5'b0) && (EX_MEM_Rd_addr == ID_EX_Rt_addr)) && 
                 (MEM_WB_Rd_addr == ID_EX_Rt_addr)) begin
            Forward_B = 2'b01;
        end
    end
endmodule
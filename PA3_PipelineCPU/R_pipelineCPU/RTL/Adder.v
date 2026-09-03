module Adder (
    input wire [31:0] Src_1,Src_2,
    output wire [31:0] Output_Addr
);
    assign Output_Addr=Src_1+Src_2;
endmodule
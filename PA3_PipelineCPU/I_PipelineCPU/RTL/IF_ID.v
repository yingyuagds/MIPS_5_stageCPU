module IF_ID (
    input  wire        clk,
    input  wire [31:0] Instr_in,
    output reg  [31:0] Instr_out
);
    always @(posedge clk) begin
        Instr_out <= Instr_in;
    end
endmodule
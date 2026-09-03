module IF_ID (
    input  wire        clk,
    input  wire        IF_ID_write,
    input  wire [31:0] Instr_in,
    output reg  [31:0] Instr_out
);
    initial Instr_out = 32'b0;
    always @(posedge clk) begin
        if (IF_ID_write) begin
            Instr_out <= Instr_in;
        end
    end
endmodule
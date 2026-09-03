module ALU(
    input wire [31:0] Rs_data, Rt_data,
    input wire [5:0]  Funct,
    input wire [4:0]  Shamt,
    output reg [31:0] Rd_data
);
    always @(*) begin
        case(Funct)
            6'b100001: Rd_data = Rs_data + Rt_data; // Addu
            6'b100011: Rd_data = Rs_data - Rt_data; // Subu
            6'b000000: Rd_data = Rt_data << Shamt;  // Sll
            6'b100101: Rd_data = Rs_data | Rt_data; // OR
            default:   Rd_data = 32'b0;
        endcase
    end
endmodule
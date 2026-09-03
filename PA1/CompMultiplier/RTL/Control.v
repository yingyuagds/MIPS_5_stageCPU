module Control(
    input clk, rst_n, start, LSB,
    output reg [1:0] funct_code,
    output reg srl_ctrl, wr_ctrl, valid
);
    parameter IDLE=2'b00;
    parameter ADD=2'b01;
    parameter SHIFT=2'b10;
    parameter DONE=2'b11;

    reg [1:0] state, next_state;
    reg [5:0] counter;
    always @(posedge clk) begin
        if (!rst_n) begin
            state<=IDLE;
            counter<=6'd0;
        end 
        else begin
            state<=next_state;
            if (state==IDLE)counter<=6'd0;
            else if (state==SHIFT) counter<=counter+6'd1;
        end
    end
    always @(*) begin
        case (state)
            IDLE: next_state=start?ADD:IDLE;
            ADD: next_state=SHIFT;
            SHIFT: next_state=(counter==6'd31)?DONE:ADD;
            DONE: next_state=IDLE;
            default: next_state=IDLE;
        endcase
    end
    always @(*) begin
        wr_ctrl=1'b0;
        srl_ctrl=1'b0;
        funct_code=2'b00;
        valid=1'b0;
        case (state)
            ADD: begin
                wr_ctrl=LSB;
                funct_code=LSB?2'b01:2'b00;
            end
            SHIFT: srl_ctrl=1'b1;
            DONE: valid=1'b1;
        endcase
    end
endmodule
module Control(
    input clk, rst_n, start,
    input [1:0] LSB,
    output reg [5:0] funct_code,
    output reg srl_ctrl, wr_ctrl, valid
);

    parameter IDLE  = 2'b00;
    parameter CALC  = 2'b01;
    parameter SHIFT = 2'b10;
    parameter DONE  = 2'b11;

    reg [1:0] state, next_state;
    reg [5:0] counter;

    // State register + counter
    always @(posedge clk) begin
        if (!rst_n) begin
            state   <= IDLE;
            counter <= 6'd0;
        end else begin
            state <= next_state;
            if (state == IDLE)
                counter <= 6'd0;
            else if (state == SHIFT)
                counter <= counter + 6'd1;
        end
    end

    // Next state
    always @(*) begin
        case (state)
            IDLE:  next_state = start? CALC: IDLE;
            CALC:  next_state = SHIFT;
            SHIFT: next_state = (counter == 6'd31) ? DONE :CALC;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        wr_ctrl    = 1'b0;
        srl_ctrl   = 1'b0;
        funct_code = 6'b000000;
        valid      = 1'b0;
        case (state)
            CALC: begin
                if (LSB==2'b01)
                begin
                    wr_ctrl=1'b1;
                    funct_code=6'b000001;
                end
                else if (LSB==2'b10)
                begin
                    wr_ctrl=1'b1;
                    funct_code=6'b000010;
                end
            end
            SHIFT: begin
                srl_ctrl = 1'b1;
            end
            DONE: begin
                valid = 1'b1;
            end
        endcase
    end

endmodule
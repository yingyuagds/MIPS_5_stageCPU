module Control(
    input clk,rst_n,start,ALU_MSB,
    output reg [1:0]funct_code,
    output reg sll_ctrl,wr_ctrl,valid
);
parameter IDLE=3'b000;
parameter SHIFT=3'b001;
parameter SUB=3'b010;
parameter CHECK=3'b011;
parameter DONE=3'b100;
reg [2:0] state,next_state;
reg [5:0] counter;
always @(posedge clk) begin
    if (!rst_n)
    begin
        state<=IDLE;
        counter<=6'b0;
    end
    else 
    begin
        state<=next_state;
        if (state==IDLE) begin
            counter <= 6'b0;
        end
        else if (state==CHECK) counter<=counter+1;
    end
end
always @(*) begin
    case(state)
        IDLE: next_state=start?SHIFT:IDLE;
        SHIFT: next_state=SUB;
        SUB: next_state=CHECK;
        CHECK: next_state=(counter==31)?DONE:SHIFT;
        DONE: next_state=IDLE;
        default: next_state=IDLE;
    endcase
end
always@(*)
begin 
    funct_code = 2'b00;
    sll_ctrl   = 1'b0;
    wr_ctrl    = 1'b0;
    valid      = 1'b0;
        case(state)
            SHIFT: sll_ctrl=1'b1;
            SUB: 
            begin
                funct_code=2'b01;
                if (ALU_MSB==1'b0) wr_ctrl=1'b1;
            end
            DONE: valid=1'b1;
        endcase
    end
endmodule

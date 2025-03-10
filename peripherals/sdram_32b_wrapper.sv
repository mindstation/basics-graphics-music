module sdram_32b_wrapper
(
    input                  clk,
    input                  rst,

    input  [         24:1] addr_i,
    input  [         31:0] wdata_32i,
    output [         31:0] rdata_32o,
    input                  wr_i,
    input                  req_i,
    output                 ack_o,

    output [         24:1] addr_o,
    output [         15:0] wdata_16o,
    input  [         15:0] rdata_16i,
    output                 wrl_o,
    output                 wrh_o,
    output                 req_o,
    input                  ack_i
);

localparam STATE_IDLE      = 3'd0;
localparam STATE_REQ       = STATE_IDLE + 1'd1;
localparam STATE_READY_LOW = STATE_REQ  + 1'd1;
localparam STATE_ACK       = STATE_READY_LOW + 1'd1;

logic [2:0] state, next_state;

always_comb
begin

    rdata_32o  = '0;
    next_wdata = '0;
    next_wr    = '0;
    next_addr  = '0;
    ack_o      = '0;

    case (state)
        STATE_IDLE: begin
            if (req_i) begin
                next_state = STATE_REQ;
                next_addr  = addr_i;
                next_wdata = wdata_32i;
                next_wr    = wr_i;
            end
            else begin
                next_state = STATE_IDLE;
            end
        end;
        STATE_REQ: begin
            
        end
    endcase

end


endmodule

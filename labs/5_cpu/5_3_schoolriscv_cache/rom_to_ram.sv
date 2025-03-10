module rom_to_ram
#(
    parameter ROM_SIZE = 64
)
(
    input               iclk,
    input               ireset,

    input               irtest,
    output logic        oloading, orerror,

// SDRAM
    input               iram_ack,
    input        [15:0] iram_data,
    output       [24:1] oram_addr,
    output logic [15:0] oram_wrdata,
    output logic        oram_req,
    output logic        oram_Wrl, oram_Wrh,

//ROM
    output       [23:1] orom_addr,
    input        [15:0] irom_data,
    output logic        orom_req,
    input               irom_ack
);

localparam    INIT          = 4'd0,
              ROM_READ      = 4'd1,
              ROM_ACK_WAIT  = 4'd2,
              RAM_WRITE     = 4'd3,
              RAM_ACK_WAIT  = 4'd4,
              ADDR_INC      = 4'd5,
              STOP          = 4'd6,
              R_INIT        = 4'd7,
              RDATA_REQ     = 4'd8,
              RDATA_READY   = 4'd9,
              RDATA_CHECK   = 4'd10,
              RDATA_ADDR    = 4'd11;

logic [3:0]  fsm_state;
logic [23:1] rom_addr_counter;
logic [24:1] ram_addr_counter;

// oram_addr[24:23] is a bank number, oram_addr[13:1] is a row number, oram_addr[22:14] is a column number
assign oram_addr = ram_addr_counter;
assign orom_addr = rom_addr_counter;

always_ff @(posedge iclk)
    begin
        if (ireset)
            fsm_state <= INIT;
        else
            case (fsm_state)
                INIT:
                    begin
                        if (irtest)
                            fsm_state <= STOP;
                        else
                            begin
                                rom_addr_counter <= 23'd0;
                                ram_addr_counter <= 24'd0;
                                oloading <= 1'b1;
                                orerror <=  1'b0;
                                // If oWrl or oWrh is 1, then write SDRAM
                                {oram_Wrl,oram_Wrh} <= 2'b11;

                                fsm_state <= ROM_READ;
                            end
                    end
                ROM_READ:
                    begin
                        ofl_req <= ~ifl_ack;
                        fsm_state <= ROM_ACK_WAIT;
                    end
                ROM_ACK_WAIT:
                    if (ofl_req == ifl_ack)
                        fsm_state <= RAM_WRITE;
                RAM_WRITE:
                    begin
                        oram_wrdata <= ifl_data;
                        oram_req <= ~iram_ack;
                        fsm_state <= RAM_ACK_WAIT;
                    end
                RAM_ACK_WAIT:
                    if (oram_req == iram_ack)
                        fsm_state <= ADDR_INC;
                ADDR_INC:
                    if (rom_addr_counter < ROM_SIZE)
                        begin
                            rom_addr_counter <= rom_addr_counter + 23'd2;
                            ram_addr_counter <= ram_addr_counter + 24'd1;
                            fsm_state <= ROM_READ;
                        end
                    else
                        fsm_state <= STOP;
                STOP:
                    begin
                        {oram_Wrl,oram_Wrh} <= 2'b00;
                        oloading <= 1'b0;
                        if (irtest)
                            fsm_state <= R_INIT;
                    end
                R_INIT:
                    begin
                        rom_addr_counter <= 23'd0;
                        ram_addr_counter <= 24'd0;
                        orerror <=  1'b0;
                        fsm_state <= RDATA_REQ;
                    end
                RDATA_REQ:
                    begin
                        ofl_req <= ~ifl_ack;
                        oram_req <= ~iram_ack;
                        fsm_state <= RDATA_READY;
                    end
                RDATA_READY:
                    begin
                        orerror <=  1'b0;
                        if ((ofl_req == ifl_ack) && (oram_req == iram_ack))
                            fsm_state <= RDATA_CHECK;
                    end
                RDATA_CHECK:
                    begin
                        if (ifl_data != iram_data)
                            orerror <= 1'b1;
                        fsm_state <= RDATA_ADDR;
                    end
                RDATA_ADDR:
                    begin
                        if (rom_addr_counter < ROM_SIZE)
                            begin
                                rom_addr_counter <= rom_addr_counter + 23'd2;
                                ram_addr_counter <= ram_addr_counter + 24'd1;
                            end
                        else
                            begin
                                rom_addr_counter <= 23'd0;
                                ram_addr_counter <= 24'd0;
                            end
                        if (irtest)
                            fsm_state <= RDATA_REQ;
                        else
                            fsm_state <= STOP;
                    end
                default:
                    fsm_state <= INIT;
            endcase;
    end
endmodule

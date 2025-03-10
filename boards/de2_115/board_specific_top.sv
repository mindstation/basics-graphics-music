`include "config.svh"
`include "lab_specific_board_config.svh"

module board_specific_top
# (
    parameter clk_mhz       = 50,
              pixel_mhz     = 25,

              w_key         = 4,
              w_sw          = 18,
              w_led         = 27,
              w_digit       = 8,
              w_gpio        = 36,

              // gpio 0..5 are reserved for INMP 441 I2S microphone.

              screen_width  = 640,
              screen_height = 480,

              w_red         = 8,
              w_green       = 8,
              w_blue        = 8,

              w_x           = $clog2 ( screen_width  ),
              w_y           = $clog2 ( screen_height )
)
(
    input                   CLOCK_50,

    input  [w_key    - 1:0] KEY,
    input  [w_sw     - 1:0] SW,

    output logic [    17:0] LEDR,  // The last 8 LEDR are used like a 7SEG dp
    output logic [     8:0] LEDG,

    output logic [     6:0] HEX0,  // HEX[7] aka dp are not connected to FPGA at DE2-115
    output logic [     6:0] HEX1,
    output logic [     6:0] HEX2,
    output logic [     6:0] HEX3,
    output logic [     6:0] HEX4,
    output logic [     6:0] HEX5,
    output logic [     6:0] HEX6,
    output logic [     6:0] HEX7,

    output                  DRAM_CLK,
    output                  DRAM_CKE,
    output [          12:0] DRAM_ADDR,
    output [           1:0] DRAM_BA,
    inout  [          31:0] DRAM_DQ,
    output [           1:0] DRAM_DQM,
    output                  DRAM_CS_N,
    output                  DRAM_CAS_N,
    output                  DRAM_RAS_N,
    output                  DRAM_WE_N,

    output                  VGA_CLK,
    output                  VGA_HS,
    output                  VGA_VS,
    output [w_red    - 1:0] VGA_R,
    output [w_green  - 1:0] VGA_G,
    output [w_blue   - 1:0] VGA_B,
    output                  VGA_BLANK_N,
    output                  VGA_SYNC_N,

    inout                   AUD_ADCLRCK,
    input                   AUD_ADCDAT,
    inout                   AUD_BCLK,
    inout                   AUD_DACLRCK,
    output                  AUD_DACDAT,
    output                  AUD_XCK,

    output                  I2C_SCLK,
    inout                   I2C_SDAT,

    input                   UART_RTS,
    input                   UART_RXD,

    output                  UART_CTS,
    output                  UART_TXD,

    inout  [w_gpio   - 1:0] GPIO
);

    //------------------------------------------------------------------------

    localparam w_lab_led = 8,         // We will actually use LEDG [7:0]
               w_lab_sw  = w_sw - 1;  // One sw is used as a reset

    //------------------------------------------------------------------------

    wire                    clk     = CLOCK_50;
    wire                    rst     = SW [w_lab_sw];

    // Switches, LEDs

    wire [ w_lab_sw  - 1:0] lab_sw  = SW [w_lab_sw - 1:0];
    wire [ w_lab_led - 1:0] lab_led;

    // A dynamic seven-segment display

    wire [             7:0] abcdefgh;
    wire [ w_digit   - 1:0] digit;

    // Graphics

    wire [ w_x       - 1:0] x;
    wire [ w_y       - 1:0] y;

    // Microphone, sound output

    wire [            23:0] mic;
    wire [            15:0] sound;

    //------------------------------------------------------------------------

    wire slow_clk;

    slow_clk_gen # (.fast_clk_mhz (clk_mhz), .slow_clk_hz (1))
    i_slow_clk_gen (.slow_clk (slow_clk), .*);

    //------------------------------------------------------------------------

    lab_top
    # (
        .clk_mhz       (   clk_mhz       ),
        .w_key         (   w_key         ),
        .w_sw          (   w_lab_sw      ),
        .w_led         (   w_lab_led     ),
        .w_digit       (   w_digit       ),
        .w_gpio        (   w_gpio        ),

        .screen_width  (   screen_width  ),
        .screen_height (   screen_height ),

        .w_red         (   w_red         ),
        .w_green       (   w_green       ),
        .w_blue        (   w_blue        )
    )
    i_lab_top
    (
        .clk           (   clk           ),
        .slow_clk      (   slow_clk      ),
        .rst           (   rst           ),

        .key           ( ~ KEY           ),
        .sw            (   lab_sw        ),

        .led           (   lab_led       ),

        .abcdefgh      (   abcdefgh      ),
        .digit         (   digit         ),

        .x             (   x             ),
        .y             (   y             ),

        .red           (   VGA_R         ),
        .green         (   VGA_G         ),
        .blue          (   VGA_B         ),

        .mic           (   mic           ),
        .sound         (   sound         ),

        .ram_addr      (   ram_addr_wrp32  ),
        .ram_wdata     (   ram_wdata_wrp32 ),
        .ram_rdata     (   ram_rdata_wrp32 ),
        .ram_wr        (   ram_wr          ),
        .ram_req       (   ram_req_wrp32   ),
        .ram_ack       (   ram_ack_wrp32   ),

        .uart_rx       (   UART_RXD      ),
        .uart_tx       (   UART_TXD      ),

        .gpio          (   GPIO          )
    );

    //------------------------------------------------------------------------

    assign LEDG = { { $bits (LEDG) - w_lab_led { 1'b0 } }, lab_led };

    //------------------------------------------------------------------------

    wire [$left (abcdefgh):0] hgfedcba;

    generate
        genvar i;

        for (i = 0; i < $bits (abcdefgh); i ++)
        begin : abc
            assign hgfedcba [i] = abcdefgh [$left (abcdefgh) - i];
        end
    endgenerate

    //------------------------------------------------------------------------

    `ifdef EMULATE_DYNAMIC_7SEG_ON_STATIC_WITHOUT_STICKY_FLOPS

        // Pro: This implementation is necessary for the lab 7segment_word
        // to properly demonstrate the idea of dynamic 7-segment display
        // on a static 7-segment display.
        //

        // Con: This implementation makes the 7-segment LEDs dim
        // on most boards with the static 7-sigment display.

        // inverted logic

        assign HEX0 = digit [0] ? ~ hgfedcba [$left (HEX0):0] : '1;
        assign HEX1 = digit [1] ? ~ hgfedcba [$left (HEX1):0] : '1;
        assign HEX2 = digit [2] ? ~ hgfedcba [$left (HEX2):0] : '1;
        assign HEX3 = digit [3] ? ~ hgfedcba [$left (HEX3):0] : '1;
        assign HEX4 = digit [4] ? ~ hgfedcba [$left (HEX4):0] : '1;
        assign HEX5 = digit [5] ? ~ hgfedcba [$left (HEX5):0] : '1;
        assign HEX6 = digit [6] ? ~ hgfedcba [$left (HEX6):0] : '1;
        assign HEX7 = digit [7] ? ~ hgfedcba [$left (HEX7):0] : '1;

        // positive logic

        always_comb
        begin
            LEDR = '0;

            for (int i = 0; i < w_digit; i ++)
                LEDR [$bits (LEDR) - w_digit + i]
                    = digit [i] ? hgfedcba [$left (HEX0) + 1] : '0;
        end

    `else

        always_ff @ (posedge clk or posedge rst)
        begin
            if (rst)
            begin
                { HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 } <= '1;
                LEDR <= '0;
            end
            else
            begin
                if (digit [0]) HEX0 <= ~ hgfedcba [$left (HEX0):0];
                if (digit [1]) HEX1 <= ~ hgfedcba [$left (HEX1):0];
                if (digit [2]) HEX2 <= ~ hgfedcba [$left (HEX2):0];
                if (digit [3]) HEX3 <= ~ hgfedcba [$left (HEX3):0];
                if (digit [4]) HEX4 <= ~ hgfedcba [$left (HEX4):0];
                if (digit [5]) HEX5 <= ~ hgfedcba [$left (HEX5):0];
                if (digit [6]) HEX6 <= ~ hgfedcba [$left (HEX6):0];
                if (digit [7]) HEX7 <= ~ hgfedcba [$left (HEX7):0];

                for (int i = 0; i < w_digit; i ++)
                    if (digit [i])
                        LEDR [$bits (LEDR) - w_digit + i] <=  hgfedcba [$left (HEX0) + 1];
            end
        end

    `endif

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_SDRAM_CONTROLLER_MODULE

        wire [24:1] ram_addr_wrp32;
        wire        ram_req_wrp32,ram_ack_wrp32;
        wire        ram_wr;
        wire [31:0] ram_wdata_wrp32, ram_rdata_wrp32;

        wire [24:1] ram_addr;
        wire        ram_req,ram_ack,wrl,wrh;
        wire [15:0] ram_wdata_16, ram_rdata_16;

        wire        clk_ram;
        wire        locked;

        pll
        i_sdram_pll
        (
            .inclk0(clk),
            .c0(),
            .c1(clk_ram), // 107.142860 MHz Is 100 better?
            .locked(locked)
        );

        sdram_32b_wrapper
        i_sdram_32b
        (
            .clk        ( clk            ),
            .rst        ( rst            ),
            
            .addr_i    ( ram_addr_wrp32  ),
            .wdata_32i ( ram_wdata_wrp32 ),
            .rdata_32o ( ram_rdata_wrp32 ),
            .wr_i      ( ram_wr          ),
            .req_i     ( ram_req_wrp32   ),
            .ack_o     ( ram_ack_wrp32   ),

            .addr_o    ( ram_addr        ),
            .wdata_16o ( ram_wdata_16    ),
            .rdata_16i ( ram_rdata_16    ),
            .wrl_o     ( wrl             ),
            .wrh_o     ( wrh             ),
            .req_o     ( ram_req         ),
            .ack_i     ( ram_ack         )
        )

        sdram
        i_sdram_ctl
        (
            .SDRAM_DQ   ( DRAM_DQ[15:0] ),   // 16 bit bidirectional data bus
            .SDRAM_A    ( DRAM_ADDR     ),   // 13 bit multiplexed address bus
            .SDRAM_DQML ( DRAM_DQM[0]   ),   // byte mask
            .SDRAM_DQMH ( DRAM_DQM[1]   ),   // byte mask
            .SDRAM_BA   ( DRAM_BA       ),   // two banks
            .SDRAM_nCS  ( DRAM_CS_N     ),   // a single chip select
            .SDRAM_nWE  ( DRAM_WE_N     ),   // write enable
            .SDRAM_nRAS ( DRAM_RAS_N    ),   // row address select
            .SDRAM_nCAS ( DRAM_CAS_N    ),   // columns address select
            .SDRAM_CLK  ( DRAM_CLK      ),
            .SDRAM_CKE  ( DRAM_CKE      ),

            .init       ( ~locked       ),
            .clk        ( clk_ram       ),

            .addr0      ( 24'b0         ),
            .din0       ( 16'b0         ),
            .dout0      (),
            .wrl0       ( 1'b0          ),
            .wrh0       ( 1'b0          ),
            .req0       ( 1'b0          ),
            .ack0       (),

            // addr1[24:23] is a bank number, addr1[13:1] is a row number, addr1[22:14] is a column number
            .addr1      ( {ram_addr[24:23],
                           ram_addr[9:1],
                           ram_addr[22:10]}),
            .din1       ( ram_wdata_16  ),
            .dout1      ( ram_rdata_16  ),
            // If wrl1 or wrh1 is 1, then write data
            .wrl1       ( wrl           ),
            .wrh1       ( wrh           ),
            .req1       ( ram_req       ),
            .ack1       ( ram_ack       ),

            .addr2      ( 24'b0         ),
            .din2       ( 16'b0         ),
            .dout2      (),
            .wrl2       ( 1'b0          ),
            .wrh2       ( 1'b0          ),
            .req2       ( 1'b0          ),
            .ack2       (),
        );

    `endif

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_GRAPHICS_INTERFACE_MODULE

        wire [9:0] x10; assign x = x10;
        wire [9:0] y10; assign y = y10;

        vga
        # (
            .H_DISPLAY   ( screen_width  ),
            .V_DISPLAY   ( screen_height ),
            .CLK_MHZ     ( clk_mhz       ),
            .PIXEL_MHZ   ( pixel_mhz     )
        )
        i_vga
        (
            .clk         ( clk           ),
            .rst         ( rst           ),
            .hsync       ( VGA_HS        ),
            .vsync       ( VGA_VS        ),
            .display_on  ( VGA_BLANK_N   ),
            .hpos        ( x10           ),
            .vpos        ( y10           ),
            .pixel_clk   ( VGA_CLK       )
        );

        assign VGA_SYNC_N = 1'b0;

    `endif

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_MICROPHONE_INTERFACE_MODULE

        inmp441_mic_i2s_receiver
        # (
            .clk_mhz ( clk_mhz  )
        )
        i_microphone
        (
            .clk     ( clk      ),
            .rst     ( rst      ),
            .lr      ( GPIO [0] ),
            .ws      ( GPIO [2] ),
            .sck     ( GPIO [4] ),
            .sd      ( GPIO [5] ),
            .value   ( mic      )
        );

        assign GPIO [1] = 1'b0;  // GND
        assign GPIO [3] = 1'b1;  // VCC

    `endif

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_SOUND_OUTPUT_INTERFACE_MODULE

        // DE2-115 onboard audio codec: WM8731
        i2s_audio_out
        # (
            .clk_mhz ( clk_mhz   )
        )
        i_audio_out
        (
            .clk     ( clk          ),
            .reset   ( rst          ),
            .data_in ( sound        ),
            .mclk    ( AUD_XCK      ),
            .bclk    ( AUD_BCLK     ),
            .lrclk   ( AUD_DACLRCK  ),
            .sdata   ( AUD_DACDAT   )
        );

        // The audio codec configuration
        I2C_AUDIO_Config
        i_i2c_codec_conf (
            .iCLK    (clk),
            .iRST_N  (~rst),
            .I2C_SCLK(I2C_SCLK),
            .I2C_SDAT(I2C_SDAT),
            .READY   ()
        );

    `endif

endmodule

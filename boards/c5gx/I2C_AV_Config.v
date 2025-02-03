// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc.
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altrea Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

module I2C_AV_Config (	//	Host Side
					iCLK,
					iRST_N,
					//	I2C Side
					I2C_SCLK,
					I2C_SDAT,
					HDMI_TX_INT,
					READY
					 );
//	Host Side
input				iCLK;
input				iRST_N;
//	I2C Side
output			I2C_SCLK;
inout				I2C_SDAT;
input				HDMI_TX_INT;
output READY ;

//	Internal Registers/Wires
reg	[15:0]	mI2C_CLK_DIV;
reg	[23:0]	mI2C_DATA;
reg				mI2C_CTRL_CLK;
reg				mI2C_GO;
wire				mI2C_END;
wire				mI2C_ACK;
reg	[15:0]	LUT_DATA;
reg	[5:0]		LUT_INDEX;
reg	[3:0]		mSetup_ST;
reg READY ;

//	Clock Setting
parameter	CLK_Freq	=	50000000;	//	50	MHz
parameter	I2C_Freq	=	20000;		//	20	KHz
//	LUT Data Number
parameter	LUT_SIZE	=	43;
//	Audio Data Index
parameter	Dummy_DATA	=	0;
parameter	SET_LIN_L	=	1;
parameter	SET_LIN_R	=	2;
parameter	SET_HEAD_L	=	3;
parameter	SET_HEAD_R	=	4;
parameter	A_PATH_CTRL	=	5;
parameter	D_PATH_CTRL	=	6;
parameter	POWER_ON	=	7;
parameter	SET_FORMAT	=	8;
parameter	SAMPLE_CTRL	=	9;
parameter	SET_ACTIVE	=	10;
//  Audio codec I2C address
parameter   AUD_I2C_ADDR =   8'h34;
//	HDMI Data Index
parameter	SET_HDMI	=	11;
//  HDMI transmitter I2C address
parameter   HDMI_I2C_ADDR =   8'h72;

/////////////////////	I2C Control Clock	////////////////////////
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		mI2C_CTRL_CLK	<=	0;
		mI2C_CLK_DIV	<=	0;
	end
	else
	begin
		if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq) )
			mI2C_CLK_DIV	<=	mI2C_CLK_DIV+1;
		else
		begin
			mI2C_CLK_DIV	<=	0;
			mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK;
		end
	end
end
////////////////////////////////////////////////////////////////////
I2C_Controller 	u0	(	.CLOCK(mI2C_CTRL_CLK),	//	Controller Work Clock
						.I2C_SCLK(I2C_SCLK),				//	I2C CLOCK
 	 	 	 	 	 	.I2C_SDAT(I2C_SDAT),				//	I2C DATA
						.I2C_DATA(mI2C_DATA),			//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
						.GO(mI2C_GO),						//	GO transfor
						.END(mI2C_END),					//	END transfor
						.ACK(mI2C_ACK),					//	ACK
						.RESET(iRST_N)	);
////////////////////////////////////////////////////////////////////
//////////////////////	Config Control	////////////////////////////
always@(posedge mI2C_CTRL_CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
	READY<=0;
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2C_GO		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
		READY<=0;
			case(mSetup_ST)
			0:	begin
					if(LUT_INDEX<SET_HDMI)
					mI2C_DATA	<=	{AUD_I2C_ADDR,LUT_DATA};
					else
					mI2C_DATA	<=	{HDMI_I2C_ADDR,LUT_DATA};
					mI2C_GO		<=	1;
					mSetup_ST	<=	1;
				end
			1:	begin
					if(mI2C_END)
					begin
						if(!mI2C_ACK)
						mSetup_ST	<=	2;
						else
						mSetup_ST	<=	0;
						mI2C_GO		<=	0;
					end
				end
			2:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mSetup_ST	<=	0;
				end
			endcase
		end
		else
		begin
		  READY<=1;
		  if(!HDMI_TX_INT)
		  begin
		    LUT_INDEX <= 0;
		  end
		  else
		    LUT_INDEX <= LUT_INDEX;
		end
	end
end
////////////////////////////////////////////////////////////////////
/////////////////////	Config Data LUT	  //////////////////////////
always
begin
	case(LUT_INDEX)
	//	Audio Config Data
	Dummy_DATA	:	LUT_DATA	<=	16'h0000;
	SET_LIN_L	:	LUT_DATA	<=	16'h001A;
	SET_LIN_R	:	LUT_DATA	<=	16'h021A;
	SET_HEAD_L	:	LUT_DATA	<=	16'h047B;
	SET_HEAD_R	:	LUT_DATA	<=	16'h067B;
	A_PATH_CTRL	:	LUT_DATA	<=	16'h08F8;
	D_PATH_CTRL	:	LUT_DATA	<=	16'h0A06;
	POWER_ON	:	LUT_DATA	<=	16'h0C00;
	SET_FORMAT	:	LUT_DATA	<=	16'h0E01;
	SAMPLE_CTRL	:	LUT_DATA	<=	16'h1002;
	SET_ACTIVE	:	LUT_DATA	<=	16'h1201;
	//	Video Config Data
	SET_HDMI+1	:	LUT_DATA	<=	16'h9803;  //Must be set to 0x03 for proper operation
	SET_HDMI+2	:	LUT_DATA	<=	16'h0100;  //Set 'N' value at 6144
	SET_HDMI+3	:	LUT_DATA	<=	16'h0218;  //Set 'N' value at 6144
	SET_HDMI+4	:	LUT_DATA	<=	16'h0300;  //Set 'N' value at 6144
	SET_HDMI+5	:	LUT_DATA	<=	16'h1470;  // Set Ch count in the channel status to 8.
	SET_HDMI+6	:	LUT_DATA	<=	16'h1520;  //Input 444 (RGB or YCrCb) with Separate Syncs, 48kHz fs
	SET_HDMI+7	:	LUT_DATA	<=	16'h1630;  //Output format 444, 24-bit input
	SET_HDMI+8	:	LUT_DATA	<=	16'h1846;  //Disable CSC
	SET_HDMI+9	:	LUT_DATA	<=	16'h4080;  //General control packet enable
	SET_HDMI+10	:	LUT_DATA	<=	16'h4110;  //Power down control
	SET_HDMI+11	:	LUT_DATA	<=	16'h49A8;  //Set dither mode - 12-to-10 bit
	SET_HDMI+12	:	LUT_DATA	<=	16'h5510;  //Set RGB in AVI infoframe
	SET_HDMI+13	:	LUT_DATA	<=	16'h5608;  //Set active format aspect
	SET_HDMI+14	:	LUT_DATA	<=	16'h96F6;  //Set interrup
	SET_HDMI+15	:	LUT_DATA	<=	16'h7307;  //Info frame Ch count to 8
	SET_HDMI+16	:	LUT_DATA	<=	16'h761f;  //Set speaker allocation for 8 channels
	SET_HDMI+17	:	LUT_DATA	<=	16'h9803;  //Must be set to 0x03 for proper operation
	SET_HDMI+18	:	LUT_DATA	<=	16'h9902;  //Must be set to Default Value
	SET_HDMI+19	:	LUT_DATA	<=	16'h9ae0;  //Must be set to 0b1110000
	SET_HDMI+20	:	LUT_DATA	<=	16'h9c30;  //PLL filter R1 value
	SET_HDMI+21	:	LUT_DATA	<=	16'h9d61;  //Set clock divide
	SET_HDMI+22	:	LUT_DATA	<=	16'ha2a4;  //Must be set to 0xA4 for proper operation
	SET_HDMI+23	:	LUT_DATA	<=	16'ha3a4;  //Must be set to 0xA4 for proper operation
	SET_HDMI+24	:	LUT_DATA	<=	16'ha504;  //Must be set to Default Value
	SET_HDMI+25	:	LUT_DATA	<=	16'hab40;  //Must be set to Default Value
	SET_HDMI+26	:	LUT_DATA	<=	16'haf16;  //Select HDMI mode
	SET_HDMI+27	:	LUT_DATA	<=	16'hba60;  //No clock delay
	SET_HDMI+28	:	LUT_DATA	<=	16'hd1ff;  //Must be set to Default Value
	SET_HDMI+29	:	LUT_DATA	<=	16'hde10;  //Must be set to Default for proper operation
	SET_HDMI+30	:	LUT_DATA	<=	16'he460;  //Must be set to Default Value
	SET_HDMI+31	:	LUT_DATA	<=	16'hfa7d;  //Nbr of times to look for good phase

	default:		LUT_DATA	<=	16'h9803;
	endcase
end
////////////////////////////////////////////////////////////////////
endmodule

# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb.i_converter.q00
lappend all_signals tb.i_converter.q90
lappend all_signals tb.i_converter.i_filtered
lappend all_signals tb.i_converter.q_filtered
lappend all_signals tb.i_converter.abs_i
lappend all_signals tb.i_converter.abs_q
lappend all_signals tb.i_converter.sum_abs
lappend all_signals tb.i_converter.ema
lappend all_signals tb.i_converter.rms_out
lappend all_signals tb.i_converter.mic
lappend all_signals tb.i_converter.switch

set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full

gtkwave::highlightSignalsFromList "tb.i_converter.q00\[7:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Signed_Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.q90\[7:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Signed_Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.i_filtered\[14:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Signed_Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.q_filtered\[14:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Signed_Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.abs_i\[14:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.abs_q\[14:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.sum_abs\[15:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.ema\[16:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.rms_out\[10:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.mic\[7:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Signed_Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::highlightSignalsFromList "tb.i_converter.switch\[4:0\]"
gtkwave::/Edit/Data_Format/Analog/Step
gtkwave::/Edit/Data_Format/Decimal
gtkwave::/Edit/Insert_Analog_Height_Extension

gtkwave::/Edit/UnHighlight_All

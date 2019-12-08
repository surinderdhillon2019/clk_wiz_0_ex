onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /clk_wiz_0_tb/i
add wave -noupdate /clk_wiz_0_tb/pcie_clk
add wave -noupdate /clk_wiz_0_tb/dac_clk
add wave -noupdate /clk_wiz_0_tb/pcie_clk_reset
add wave -noupdate /clk_wiz_0_tb/dac_clk_reset
add wave -noupdate /clk_wiz_0_tb/reset
add wave -noupdate /clk_wiz_0_tb/power_down
add wave -noupdate /clk_wiz_0_tb/input_clk_stopped
add wave -noupdate /clk_wiz_0_tb/locked
add wave -noupdate /clk_wiz_0_tb/CLK_OUT
add wave -noupdate /clk_wiz_0_tb/period1
add wave -noupdate /clk_wiz_0_tb/prev_rise1
add wave -noupdate -radix ascii /clk_wiz_0_tb/test_phase
add wave -noupdate /glbl/GSR
add wave -noupdate -divider DUT
add wave -noupdate -color Magenta /clk_wiz_0_tb/dut/clk_in1
add wave -noupdate -color Magenta /clk_wiz_0_tb/dut/CLK_OUT
add wave -noupdate /clk_wiz_0_tb/dut/state
add wave -noupdate -color Orange /clk_wiz_0_tb/dut/pcie_clk
add wave -noupdate -color Cyan /clk_wiz_0_tb/dut/dac_clk
add wave -noupdate /clk_wiz_0_tb/dut/counter
add wave -noupdate /clk_wiz_0_tb/dut/reset
add wave -noupdate /clk_wiz_0_tb/dut/locked
add wave -noupdate /clk_wiz_0_tb/dut/select_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {580444 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 316
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1811250 ps}

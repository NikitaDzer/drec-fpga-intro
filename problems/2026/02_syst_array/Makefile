TOP_TB_NAME := sa_top_tb

TB_LIST := sa_top_tb.sv sa_top_tb.cc

RTL_LIST :=  \
	syst_array/sr.sv \
	syst_array/pe.sv \
	syst_array/delay_line.sv \
	syst_array/delay_line_rev.sv \
	syst_array/we_line.sv \
	syst_array/sa_core.sv \
	syst_array/sa_top.sv

VCD_FILE := dump.vcd

ifeq ($(GUI), 1)
VSIM_FLAGS :=
else
VSIM_FLAGS := -c -do 'vcd file $(VCD_FILE); vcd add -r /$(TOP_TB_NAME)/*; run -all'
endif

vsim: $(TB_LIST) $(RTL_LIST)
	vlog $^
	vsim work.$(TOP_TB_NAME) $(VSIM_FLAGS) $(VSIM_LIBS)

verilator: $(TB_LIST) $(RTL_LIST)
	verilator --binary -Wno-fatal --trace $^
	./obj_dir/V$(TOP_TB_NAME)

lint: $(RTL_LIST)
	verilator --lint-only $^

clean:
	rm -rf transcript work obj_dir

waves: $(VCD_FILE)
	gtkwave $(VCD_FILE) &

.PHONY: clean verilator waves vsim

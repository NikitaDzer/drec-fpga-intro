SIM ?= verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES += \
	sa_credit_based.sv \
	syst_array/sa_top.sv \
	syst_array/sa_core.sv \
	syst_array/pe.sv \
	syst_array/sr.sv \
	syst_array/we_line.sv \
	syst_array/delay_line.sv \
	syst_array/delay_line_rev.sv \
	ctrl/credit.sv \
	ctrl/fifo.sv \
	addr_gen/axi_addr_gen.sv \
	axi_sa.sv \
	axi_sa_top.sv




TOPLEVEL = axi_sa_top
MODULE   = axi_sa_top_tb

ifeq ($(SIM), verilator)
    EXTRA_ARGS += --trace --trace-fst --trace-structs
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

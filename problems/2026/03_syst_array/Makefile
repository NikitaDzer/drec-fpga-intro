SIM ?= verilator

TOPLEVEL_LANG = verilog

VERILOG_SOURCES += \
	syst_array/sa_top.sv \
	syst_array/sa_core.sv \
	syst_array/pe.sv \
	syst_array/sr.sv \
	syst_array/we_line.sv \
	syst_array/delay_line.sv \
	syst_array/delay_line_rev.sv \
	credit/credit.sv \
	credit/fifo.sv \
	sa_credit_top.sv


TOPLEVEL = sa_credit_top
MODULE   = sa_credit_top_tb

ifeq ($(SIM), verilator)
    EXTRA_ARGS += --trace --trace-fst --trace-structs
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

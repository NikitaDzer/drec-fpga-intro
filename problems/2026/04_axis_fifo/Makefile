SIM ?= verilator
WAVES ?= 0
COV ?= 0

VERILOG_SOURCES :=  \
	src/fifo_axis.sv \
	src/fifo.sv \
	fifo_axis_top.sv

.PHONY: lint

MODULE   = fifo_axis_top_tb
TOPLEVEL = fifo_axis_top

ifeq ($(SIM),verilator)
ifeq ($(WAVES),1)
	EXTRA_ARGS += --trace --trace-fst --trace-structs
endif
ifeq ($(COV),1)
	EXTRA_ARGS += --coverage
endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

lint: $(VERILOG_SOURCES)
	verilator --lint-only $^

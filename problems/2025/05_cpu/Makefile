TB_LIST := src/system_top_tb.v

RTL_LIST := 		\
	src/alu.v		\
	src/bu.v		\
	src/core.v		\
	src/cpu_top.v	\
	src/system_top.v	\
	src/core.v		\
	src/decoder.v	\
	src/decoder_imm.v	\
	src/decoder_rv32i_alu.v	\
	src/decoder_rv32i_cbu.v	\
	src/decoder_rv32i_lsu.v	\
	src/hex_display.v	\
	src/dmem.v		\
	src/imem.v		\
	src/reg_file.v	\
	src/lsu.v	\
	src/mem_xbar.v	\
	src/mmio_xbar.v	\
	src/sign_ext.v

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -I./src/ $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd &

samples:
	$(MAKE) -C samples/

syn:
	quartus_sh --flow compile fpga

gui:
	quartus fpga &

fpga:
	quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output/fpga.sof"

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output fpga.qws greybox_tmp *.bak
	$(MAKE) -C samples/ clean

.PHONY: syn fpga clean samples gui sim waves

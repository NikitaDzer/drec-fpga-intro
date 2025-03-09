test: lfsr_tb.v lfsr.v shiftreg.v
	iverilog $^ -o $@
	./test

clean:
	rm -f test

help:
	@echo "  test	   - Run testbench for lfsr"
	@echo "  clean 	   - Remove most generated files"
	@echo "  help  	   - Display this text"

.PHONY: clean test help

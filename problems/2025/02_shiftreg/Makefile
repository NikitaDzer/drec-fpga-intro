test: shiftreg_tb.v shiftreg.v
	iverilog $^ -o $@
	./test

clean:
	rm -f test

help:
	@echo "  test	   - Run testbench for shift reg"
	@echo "  clean 	   - Remove most generated files"
	@echo "  help  	   - Display this text"

.PHONY: clean test help

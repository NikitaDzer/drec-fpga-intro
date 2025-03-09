test: fifo_tb.v fifo.v
	iverilog $^ -o $@
	./test

clean:
	rm -f test

help:
	@echo "  test	   - Run testbench for fifo"
	@echo "  clean 	   - Remove most generated files"
	@echo "  help  	   - Display this text"

.PHONY: clean test help

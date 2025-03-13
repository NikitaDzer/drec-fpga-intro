test: testbench.v alu.v
	iverilog $^ -o $@
	./test

clean:
	rm -f test

help:
	@echo "  test	   - Run testbench for alu"
	@echo "  clean 	   - Remove most generated files"
	@echo "  help  	   - Display this text"

.PHONY: clean test help

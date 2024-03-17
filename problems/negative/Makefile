test: runner 
	./runner

runner: testbench.v neg_moore.v neg_mealy.v
	iverilog $^ -o $@

clean:
	rm -f runner 

help:
	@echo "  test  - Run testbench"
	@echo "  clean - Remove most generated files"
	@echo "  help  - Display this text"

.PHONY: clean test help

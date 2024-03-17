test: runner 
	./runner

runner: testbench.v negative.v
	iverilog $^ -o $@

clean:
	rm -f runner 

help:
	@echo "  test  - Run testbench"
	@echo "  clean - Remove most generated files"
	@echo "  help  - Display this text"

.PHONY: clean test help

test: reg_file_tb.v reg_file.v
	iverilog $^ -o $@
	./test

clean:
	rm -f test

help:
	@echo "  test	   - Run testbench for reg file"
	@echo "  clean 	   - Remove most generated files"
	@echo "  help  	   - Display this text"

.PHONY: clean test help

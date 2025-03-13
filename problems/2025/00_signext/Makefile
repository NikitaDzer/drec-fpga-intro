test: test_sign_ext
	./test_sign_ext

test_sign_ext: testbench.v sign_ext_beh.v sign_ext_structural.v copy_bit.v
	iverilog $^ -o $@

clean:
	rm -f test_sign_ext

help:
	@echo "  test  - Run testbench"
	@echo "  clean - Remove most generated files"
	@echo "  help  - Display this text"

.PHONY: clean test help

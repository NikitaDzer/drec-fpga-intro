TARGET = uart
SRC = testbench.v strobe.v tx.v rx.v

test: $(TARGET)
	./$(TARGET)

$(TARGET): $(SRC)
	iverilog $^ -o $@

clean:
	rm -f $(TARGET)

help:
	@echo "  test  - Run testbench"
	@echo "  clean - Remove most generated files"
	@echo "  help  - Display this text"

.PHONY: clean test help

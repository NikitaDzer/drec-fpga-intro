RISCV_PREFIX=riscv64-linux-gnu-

AS=$(RISCV_PREFIX)as
LD=$(RISCV_PREFIX)ld
OBJCOPY=$(RISCV_PREFIX)objcopy
OBJDUMP=$(RISCV_PREFIX)objdump

SRCS=$(wildcard *.s)
TXTS=$(SRCS:%.s=%.txt)

all: $(TXTS)

fib:
	riscv64-linux-gnu-gcc -nostdlib -fomit-frame-pointer -O1 -mabi=ilp32 -march=rv32i -c fib_riscv.c -o fib_riscv.o
	riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -c loader.s -o loader.o
	riscv64-linux-gnu-ld -Ttext=0x1000 -melf32lriscv loader.o fib_riscv.o -o fib_riscv.out
	make fib_riscv.txt

factorial:
	riscv64-linux-gnu-gcc -nostdlib -fomit-frame-pointer -O1 -mabi=ilp32 -march=rv32im -c fact_riscv.c -o fact_riscv.o
	riscv64-linux-gnu-as -march=rv32im -mabi=ilp32 -c loader.s -o loader.o
	riscv64-linux-gnu-ld -Ttext=0x1000 -melf32lriscv loader.o fact_riscv.o -o fact_riscv.out
	make fact_riscv.txt

%.txt: %.bin
	hexdump -v -e '"%08x\n"' $^ > $@

%.bin: %.out
	$(OBJCOPY) -O binary $^ $@

%.out: %.o
	$(LD) -melf32lriscv $^ -o $@ && $(OBJDUMP) -d $@

%.o: %.s
	$(AS) -march=rv32i -mabi=ilp32 -c $^ -o $@

.PHONY: all clean

.PRECIOUS: %.o %.out %.bin

clean:
	rm -f *.o *.out *.bin *.txt

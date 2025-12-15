import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray, Range

WIDTH = 16
SIZE = 4


def pack_words(words):
    value = 0
    for word in words:
        value = (value << WIDTH) | (word & ((1 << WIDTH) - 1))
    return value


def set_input(dut, vld, rdy, data):
    dut.i_vld.value = int(vld)
    dut.i_rdy.value = int(rdy)
    dut.i_ab_line.value = pack_words(data)


async def reset_dut(dut):
    dut.rst_n.value = 0
    await Timer(5, unit="ns")
    dut.rst_n.value = 1
    await Timer(5, unit="ns")


@cocotb.test()
async def test_idle(dut):
    cocotb.start_soon(Clock(dut.clk, 1, unit="ns").start())
    set_input(dut=dut, vld=0, rdy=0, data=[0,0,0,0])
    await reset_dut(dut)

    set_input(dut=dut, vld=0, rdy=0, data=[0,0,0,0])
    for _ in range(10 * SIZE):
        await RisingEdge(dut.clk)
    assert dut.o_vld.value == 0, "o_vld should be low during idle"

    set_input(dut=dut, vld=0, rdy=1, data=[0,0,0,0])
    for _ in range(10 * SIZE):
        await RisingEdge(dut.clk)
    assert dut.o_vld.value == 0, "o_vld should be low during idle"


@cocotb.test()
async def test_backpressure(dut):
    cocotb.start_soon(Clock(dut.clk, 1, unit="ns").start())
    set_input(dut=dut, vld=0, rdy=0, data=[0,0,0,0])
    await reset_dut(dut)

    set_input(dut=dut, vld=1, rdy=0, data=[0,0,0,0])
    for _ in range(10 * SIZE):
        await RisingEdge(dut.clk)

    assert dut.o_rdy.value == 0, "o_rdy should be low during backpressure"


@cocotb.test()
async def test_normal(dut):
    cocotb.start_soon(Clock(dut.clk, 1, unit="ns").start())
    set_input(dut=dut, vld=0, rdy=0, data=[0,0,0,0])
    await reset_dut(dut)

    set_input(dut=dut, vld=1, rdy=1, data=[0,1,2,3])
    counter = 4 * SIZE
    while (counter > 0 and dut.o_vld.value != 1):
        counter -= 1
        await RisingEdge(dut.clk)
    assert counter > 0, "o_vld has been waiting for too long"

    assert dut.o_vld.value == 1 and dut.o_c_line.value == pack_words([14,14,14,14]), "invalid o_vld or o_c_line" 
    await RisingEdge(dut.clk)

    assert dut.o_vld.value == 1 and dut.o_c_line.value == pack_words([14,14,14,14]), "invalid o_vld or o_c_line" 
    await RisingEdge(dut.clk)

    assert dut.o_vld.value == 1 and dut.o_c_line.value == pack_words([14,14,14,14]), "invalid o_vld or o_c_line" 
    await RisingEdge(dut.clk)

    assert dut.o_vld.value == 1 and dut.o_c_line.value == pack_words([14,14,14,14]), "invalid o_vld or o_c_line" 
    await RisingEdge(dut.clk)

    assert dut.o_vld.value == 0, "o_vld should be low after calculation"

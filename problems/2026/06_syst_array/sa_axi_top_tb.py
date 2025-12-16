import cocotb
from cocotb.triggers import RisingEdge, Timer, ClockCycles, First
from cocotb.clock import Clock
from cocotb.queue import Queue
import numpy as np
import random
import logging
from cocotbext.axi import AxiBus, AxiSlave, AxiRam

WIDTH = 16
SIZE = 4
AXI_DATA_WIDTH = WIDTH * SIZE

class SATestbench:
    def __init__(self, dut):
        self.dut = dut
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.INFO)
        
        self.setup_axi_slave()
        
        self.matrix_a = None
        self.matrix_b = None
        self.matrix_c = None

        self.matrix_a_addr = 0x1000
        self.matrix_b_addr = 0x2000
        self.matrix_c_addr = 0x3000
        

    def setup_axi_slave(self):
        self.axi_ram = AxiRam(
            AxiBus.from_prefix(self.dut, "m_axi"),
            self.dut.clk,
            self.dut.rst_n,
            reset_active_level=False,
            size=2**16
        )
    

    async def reset(self):
        self.dut.rst_n.value = 0
        self.dut.i_start.value = 0
        await ClockCycles(self.dut.clk, 5)
        self.dut.rst_n.value = 1
        await ClockCycles(self.dut.clk, 5)
        

    def generate_matrix(self, base_value):
        matrix = np.zeros((SIZE, SIZE), dtype=np.uint16)
        for i in range(SIZE):
            for j in range(SIZE):
                matrix[i][j] = base_value + i * SIZE + j
        return matrix
    

    def matrix_to_axi(self, matrix):
        byte_data = bytearray()
        for i in range(SIZE):
            for j in range(SIZE):
                byte_data.extend(matrix[i][j].tobytes())
        return bytes(byte_data)
    

    def axi_to_matrix(self, byte_data):
        matrix = np.zeros((SIZE, SIZE), dtype=np.uint16)
        for i in range(SIZE):
            for j in range(SIZE):
                idx = (i * SIZE + j) * 2
                matrix[i][j] = int.from_bytes(byte_data[idx:idx+2], 'little')
        return matrix
    

    async def write_matrix_to_memory(self, addr, matrix):
        byte_data = self.matrix_to_axi(matrix)
        self.axi_ram.write(addr, byte_data)
        await ClockCycles(self.dut.clk, 5)
        
        self.log.info(f"Written matrix to address 0x{addr:08x}, size {len(byte_data)} bytes")
    

    async def read_matrix_from_memory(self, addr):
        byte_len = AXI_DATA_WIDTH * SIZE
        byte_data = self.axi_ram.read(addr, byte_len)
        matrix = self.axi_to_matrix(byte_data)
        
        self.log.info(f"Read matrix from address 0x{addr:08x}")
        return matrix
    

    async def load_matrix_b(self, base_value):
        self.matrix_b = self.generate_matrix(base_value)
        self.dut.i_ab_addr.value = self.matrix_b_addr
        
        await self.write_matrix_to_memory(
            0x2000,
            self.matrix_b
        )
        
        self.dut.i_start.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.i_start.value = 0
        await ClockCycles(self.dut.clk, 4 * SIZE)
    

    async def load_matrix_a(self, base_value):
        self.matrix_a = self.generate_matrix(base_value)
        self.dut.i_ab_addr.value = self.matrix_a_addr
        self.dut.i_c_addr.value = self.matrix_c_addr
        
        await self.write_matrix_to_memory(
            self.matrix_a_addr,
            self.matrix_a
        )
        
        self.dut.i_start.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.i_start.value = 0
        await ClockCycles(self.dut.clk, 4 * SIZE) 

        
    async def store_matrix_c(self):
        self.matrix_c = await self.read_matrix_from_memory(self.matrix_c_addr)


    async def verify_results(self):
        matrix_c_ref = np.zeros((SIZE, SIZE), dtype=np.uint16)

        for i in range(SIZE):
            for j in range(SIZE):
                
                # Matrix B is transposed during SA calculation
                C = 0;
                for k in range(SIZE):
                    C += self.matrix_a[i][k] * self.matrix_b[j][k]
                matrix_c_ref[i][j] = C
            
        mismatch = np.any(self.matrix_c != matrix_c_ref)
            
        self.log.info("A:")
        self.log.info(self.matrix_a)
        self.log.info("B:")
        self.log.info(self.matrix_b)
        self.log.info("C:")
        self.log.info(self.matrix_c)
        self.log.info("C ref:")
        self.log.info(matrix_c_ref)

        assert mismatch == 0, "Failed SA calculation A x B != C"
    

    async def run_test(self, base_value):
        self.log.info("Loading matrix B")
        await self.load_matrix_b(base_value)
        
        self.log.info("Loading matrix A")
        await self.load_matrix_a(10 * base_value)
        
        self.log.info("Storing matrix C")
        await self.store_matrix_c()

        self.log.info("Verifying matrix C")
        await self.verify_results()
        

@cocotb.test()
async def test_one_run(dut):
    tb = SATestbench(dut)
    
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    
    await tb.reset()
    await tb.run_test(0)

@cocotb.test()
async def test_multiple_runs(dut):
    tb = SATestbench(dut)
    
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    
    await tb.reset()
    
    for i in range(3):
        tb.log.info(f"\nIteration {i+1}")
        await tb.run_test(i)        


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# (Expected PC, Expected Result [None if don't care], Instruction Description)
TEST_VECTORS = [
    (0,  5,          "addi x1, x0, 5        [x1 = 5]"),
    (4,  10,         "addi x2, x0, 10       [x2 = 10]"),
    (8,  15,         "add x3, x1, x2        [x3 = 15]"),
    (12, 10,         "sub x4, x3, x1        [x4 = 10]"),
    (16, 0,          "and x5, x1, x2        [x5 = 0]"),
    (20, 15,         "or x6, x1, x2         [x6 = 15]"),
    (24, 15,         "xor x7, x1, x2        [x7 = 15]"),
    (28, 160,        "sll x8, x1, x1        [x8 = 160]"),
    (32, 5,          "srl x9, x8, x1        [x9 = 5]"),
    (36, 1,          "slt x10, x1, x2       [x10 = 1]"),
    (40, 0,          "sltu x11, x2, x1      [x11 = 0]"),
    (44, 0x12345000, "lui x12, 0x12345      [x12 = 0x12345000]"),
    (48, 0x01000030, "auipc x13, 0x1000    [x13 = PC(48) + 0x01000000]"),
    (52, None,       "sw x3, 4(x0)          [Store 15 at byte 4]"),
    (56, None,       "sb x1, 8(x0)          [Store byte 5 at byte 8]"),
    (60, 15,         "lw x14, 4(x0)         [Load word 15 from byte 4]"),
    (64, 5,          "lb x15, 8(x0)         [Load byte 5 from byte 8]"),
    (68, 72,         "jal x16, 8            [Jump to PC=76, link x16=72]"),
    (76, None,       "bne x1, x2, 8         [Branch taken, jump to PC=84]"),
    (84, 42,         "addi x19, x0, 42      [x19 = 42]"),
    (88, 92,         "jalr x0, 0(x16)       [Return to PC=72 using x16]"),
    (72, 99,         "addi x17, x0, 99      [Return target executed: x17 = 99]"),
]

@cocotb.test()
async def riscv_hardware_test(dut):
    """
    Automated self-checking verification for the complete RV32I core.
    Validates arithmetic, logic, shifts, comparisons, upper immediates,
    memory (sub-word & word), and control flow (branch, jal, jalr).
    """
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    dut._log.info("=" * 70)
    dut._log.info("Starting RISC-V RV32I Processor Hardware Verification")
    dut._log.info("=" * 70)

    # 1. Reset sequence
    dut.reset.value = 1
    await Timer(25, units="ns")
    dut.reset.value = 0
    await Timer(1, units="ns")

    dut._log.info(f"{'STEP':<5} | {'PC':<8} | {'RESULT':<12} | {'STATUS':<6} | INSTRUCTION")
    dut._log.info("-" * 70)

    # 2. Cycle-by-cycle self-checking execution
    for step, (expected_pc, expected_res, desc) in enumerate(TEST_VECTORS):
        current_pc = int(dut.out_pc.value)
        current_result = int(dut.out_result.value)

        # Verify Program Counter
        assert current_pc == expected_pc, (
            f"Step {step:02d} FAILED: PC mismatch! Expected 0x{expected_pc:X} ({expected_pc}), "
            f"got 0x{current_pc:X} ({current_pc}) on '{desc}'"
        )

        # Verify Result (if applicable)
        if expected_res is not None:
            assert current_result == expected_res, (
                f"Step {step:02d} FAILED: Result mismatch! Expected 0x{expected_res:X} ({expected_res}), "
                f"got 0x{current_result:X} ({current_result}) on '{desc}'"
            )

        dut._log.info(
            f"{step+1:02d}    | 0x{current_pc:04X}   | 0x{current_result:08X} | PASS   | {desc}"
        )

        # Step forward 1 clock cycle
        await RisingEdge(dut.clk)
        await Timer(1, units="ns")

    dut._log.info("-" * 70)
    dut._log.info("ALL RV32I HARDWARE ASSERTIONS PASSED SUCCESSFULLY!")
    dut._log.info("=" * 70)
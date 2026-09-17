# RISC-V RV32I Single-Cycle Processor Core (VHDL)

A fully synthesizable, single-cycle 32-bit RISC-V processor implementing the **RV32I Base Integer Instruction Set** in VHDL. Designed for FPGA implementation (Intel / Altera Cyclone IV) and verified through ModelSim simulation and Cocotb co-simulation.

---

## Architecture Overview

The core follows a single-cycle Harvard datapath architecture:
- **ISA**: RISC-V RV32I Base Integer Instruction Set (Unprivileged)
- **Datapath**: Single-cycle execution with separate instruction and data memories
- **Register File**: 32 × 32-bit registers, dual asynchronous read ports, single synchronous write port with hardwired zero (`x0 = 0`)
- **Arithmetic Logic Unit (ALU)**: 4-bit control supporting all standard RV32I arithmetic, logical, shift, and comparison operations
- **Branch Unit**: Evaluates conditional branches (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`) using signed and unsigned comparisons
- **Jump & Link**: Full return address writeback (`PC + 4`) support for `JAL` and `JALR`
- **Memory Subsystem**: 256-byte data memory with byte-level masking for sub-word accesses (`LB`, `LBU`, `LH`, `LHU`, `LW`, `SB`, `SH`, `SW`)

---

## Supported Instructions

| Type | Instruction | Description |
| :--- | :--- | :--- |
| **R-Type** | `ADD`, `SUB` | Register addition and subtraction |
| | `SLL`, `SRL`, `SRA` | Logical left, logical right, and arithmetic right shifts |
| | `SLT`, `SLTU` | Signed and unsigned set-less-than comparisons |
| | `XOR`, `OR`, `AND` | Bitwise logical operations |
| **I-Type ALU** | `ADDI`, `SLTI`, `SLTIU` | Immediate arithmetic and comparisons |
| | `XORI`, `ORI`, `ANDI` | Immediate bitwise operations |
| | `SLLI`, `SRLI`, `SRAI` | Immediate shifts |
| **Loads** | `LW`, `LH`, `LHU`, `LB`, `LBU` | Word, halfword, and byte loads (signed / unsigned) |
| **Stores** | `SW`, `SH`, `SB` | Word, halfword, and byte stores |
| **Branches** | `BEQ`, `BNE` | Branch if equal / not equal |
| | `BLT`, `BGE` | Signed branch if less than / greater or equal |
| | `BLTU`, `BGEU` | Unsigned branch if less than / greater or equal |
| **Upper Imm** | `LUI` | Load upper 20-bit immediate |
| | `AUIPC` | Add upper immediate to Program Counter |
| **Jumps** | `JAL` | Direct jump and link |
| | `JALR` | Indirect register jump and link |

---

## Repository Structure

```text
├── ADD4.vhd                 # Dedicated PC + 4 adder
├── alu.vhd                  # 4-bit RV32I Arithmetic Logic Unit
├── ALU_MUX.vhd              # ALU operand multiplexer
├── branch_unit.vhd          # Branch condition evaluator & target calculator
├── control_unit.vhd         # Main opcode decoder and ALU decoder
├── data_memory.vhd          # Data RAM with sub-word load/store support
├── instruction_memory.vhd   # Instruction ROM initialized with test program
├── pc.vhd                   # Synchronous Program Counter register
├── PCMUX.vhd                # PC source multiplexer
├── register_file.vhd        # 32x32-bit register file (x0 = 0 guarded)
├── riscv_top.vhd            # Top-level structural entity
├── sign_extender.vhd        # Immediate generator (I, S, B, U, J formats)
├── tb_riscv_top.vhd         # Standalone VHDL testbench with cycle telemetry
├── test_riscv_cocotb.py     # Cocotb verification testbench
├── run_test.py              # Cocotb Python runner script
├── Makefile                 # Cocotb Makefile configuration
├── RISC-V.qpf               # Intel Quartus II Project File
├── RISC-V.qsf               # Intel Quartus II Settings File
├── .gitignore               # Excludes EDA build artifacts and virtualenvs
└── README.md                # Project documentation
```

---

## Simulation & Verification

### Standalone VHDL Simulation (ModelSim / QuestaSim)

To compile and simulate the complete core directly using ModelSim:

```bash
# 1. Create work library
vlib work

# 2. Compile all design units and testbench
vcom -2008 ADD4.vhd alu.vhd ALU_MUX.vhd branch_unit.vhd control_unit.vhd data_memory.vhd instruction_memory.vhd pc.vhd register_file.vhd sign_extender.vhd riscv_top.vhd tb_riscv_top.vhd

# 3. Run simulation in batch mode
vsim -c -do "run 300 ns; quit -f" tb_riscv_top
```

### Python Co-Simulation (Cocotb)

```bash
python run_test.py
```

---

## FPGA Synthesis (Intel Quartus II)

The design is synthesized and verified using **Quartus II 13.1**:
- **Target Device**: Cyclone IV GX (`EP4CGX15BF14A7`)
- **Synthesis Command**:
  ```bash
  quartus_map RISC-V
  ```
- **Result**: Analysis & Synthesis passes with **0 Errors** and 0 latch warnings.

---

## License

MIT License. Open source and available for educational, research, and hobbyist processor development.

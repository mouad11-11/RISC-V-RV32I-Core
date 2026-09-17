# ==========================================
# Cocotb Makefile for RISC-V Processor
# ==========================================

# 1. Default settings for ModelSim
SIM ?= modelsim
TOPLEVEL_LANG ?= vhdl

# 2. List all VHDL files using exact file casing (Linux/Windows compatible)
VHDL_SOURCES += ADD4.vhd
VHDL_SOURCES += alu.vhd
VHDL_SOURCES += ALU_MUX.vhd
VHDL_SOURCES += branch_unit.vhd
VHDL_SOURCES += control_unit.vhd
VHDL_SOURCES += data_memory.vhd
VHDL_SOURCES += instruction_memory.vhd
VHDL_SOURCES += pc.vhd
VHDL_SOURCES += register_file.vhd
VHDL_SOURCES += sign_extender.vhd
VHDL_SOURCES += riscv_top.vhd

# 3. Define the Top-Level VHDL Entity
TOPLEVEL = riscv_top

# 4. Define the Python Test Module (name of the Python file without .py)
MODULE = test_riscv_cocotb

# 5. Include the cocotb make rules portably
COCOTB_MAKEFILES ?= $(shell cocotb-config --makefiles 2>/dev/null || echo venv/Lib/site-packages/cocotb_tools/makefiles)
include $(COCOTB_MAKEFILES)/Makefile.sim
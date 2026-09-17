# ==========================================
# Cocotb Makefile for RISC-V Processor
# ==========================================

# 1. Default settings for ModelSim
SIM ?= modelsim
TOPLEVEL_LANG ?= vhdl

# 2. List all VHDL files using relative paths
# This avoids spaces in absolute paths (like "RISC-V -") breaking the compiler
VHDL_SOURCES += add4.vhd
VHDL_SOURCES += alu.vhd
VHDL_SOURCES += alu_mux.vhd
VHDL_SOURCES += branch_unit.vhd
VHDL_SOURCES += control_unit.vhd
VHDL_SOURCES += data_memory.vhd
VHDL_SOURCES += instruction_memory.vhd
VHDL_SOURCES += pc.vhd
VHDL_SOURCES += pcmux.vhd
VHDL_SOURCES += register_file.vhd
VHDL_SOURCES += sign_extender.vhd
VHDL_SOURCES += riscv_top.vhd

# 3. Define the Top-Level VHDL Entity
TOPLEVEL = riscv_top

# 4. Define the Python Test Module (name of the Python file without .py)
MODULE = test_riscv_cocotb

# 5. Include the cocotb make rules using a relative path to your local venv
# This completely prevents GNU make from splitting on the space in your folder name!
include venv/Lib/site-packages/cocotb_tools/makefiles/Makefile.sim
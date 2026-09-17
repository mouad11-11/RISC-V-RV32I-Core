import os
from pathlib import Path
from cocotb_tools.runner import get_runner

def run_simulation():
    sim = os.getenv("SIM", "questa")
    proj_path = Path(".")
    vhdl_sources = [
        proj_path / "ADD4.vhd",
        proj_path / "alu.vhd",
        proj_path / "ALU_MUX.vhd",
        proj_path / "branch_unit.vhd",
        proj_path / "control_unit.vhd",
        proj_path / "data_memory.vhd",
        proj_path / "instruction_memory.vhd",
        proj_path / "pc.vhd",
        proj_path / "register_file.vhd",
        proj_path / "sign_extender.vhd",
        proj_path / "riscv_top.vhd"
    ]
    runner = get_runner(sim)
    print(f"[*] Compiling VHDL files with {sim}...")
    runner.build(
        vhdl_sources=vhdl_sources,
        build_dir="sim_build"
    )
    print("[*] Starting co-simulation with Python testbench...")
    runner.test(
        toplevel="riscv_top",
        py_module="test_riscv_cocotb",
    )

if __name__ == "__main__":
    run_simulation()
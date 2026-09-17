library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_top is
    Port ( 
        clk        : in STD_LOGIC;
        reset      : in STD_LOGIC;
        out_pc     : out STD_LOGIC_VECTOR(31 downto 0);
        out_result : out STD_LOGIC_VECTOR(31 downto 0)
    );
end riscv_top;

architecture Structural of riscv_top is

    -- ==========================================
    -- 1. SIGNAL DECLARATIONS (The Wires)
    -- ==========================================
    
    -- Datapath Signals
    signal PC, PCNext, PCPlus4, PCTarget : STD_LOGIC_VECTOR(31 downto 0);
    signal PCJalrTarget                  : STD_LOGIC_VECTOR(31 downto 0);
    signal Instr                         : STD_LOGIC_VECTOR(31 downto 0);
    signal RD1, RD2                      : STD_LOGIC_VECTOR(31 downto 0);
    signal ImmExt                        : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcA, SrcB                    : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult, ReadData, Result   : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Control Signals
    signal MemWrite, ALUSrc, ALUSrcA, RegWrite : STD_LOGIC;
    signal Jump, JalrMux, Branch               : STD_LOGIC;
    signal BranchTaken                         : STD_LOGIC;
    signal Zero                                : STD_LOGIC;
    signal ResultSrc                           : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUControl                          : STD_LOGIC_VECTOR(3 downto 0);

    -- ==========================================
    -- 2. SYNTHESIS ATTRIBUTES (The Software Switches)
    -- ==========================================
    attribute keep : boolean;
    attribute keep of PC        : signal is true;
    attribute keep of Instr     : signal is true;
    attribute keep of ALUResult : signal is true;
    attribute keep of Result    : signal is true;

begin

    -- ==========================================
    -- 3. PROGRAM COUNTER ROUTING
    -- ==========================================
    
    -- Calculate JALR target: (RD1 + ImmExt) with LSB cleared to 0
    PCJalrTarget <= std_logic_vector((unsigned(RD1) + unsigned(ImmExt)) and not to_unsigned(1, 32));

    -- PC Next Selection (Sequential, Branch Target, JAL Target, JALR Target)
    PCNext <= PCJalrTarget when (Jump = '1' and JalrMux = '1') else
              PCTarget     when (Jump = '1' or BranchTaken = '1') else
              PCPlus4;

    -- 1. Program Counter Register
    u_PC: entity work.pc
        port map(
            clk     => clk,
            rst     => reset,      
            pc_next => PCNext,     
            pc_out  => PC          
        );

    -- 2. PC + 4 Adder
    u_ADD4: entity work.ADD4
        port map(a => PC, y => PCPlus4);
          
    -- 3. Instruction Memory
    u_InstrMem: entity work.instruction_memory
        port map(pc => PC, inst => Instr);

    -- 4. Control Unit
    u_ControlUnit: entity work.control_unit
        port map(
            op         => Instr(6 downto 0), 
            funct3     => Instr(14 downto 12), 
            funct7_5   => Instr(30),
            Zero       => Zero,       
            PCSrc      => open,       
            ResultSrc  => ResultSrc, 
            MemWrite   => MemWrite,
            ALUControl => ALUControl, 
            ALUSrc     => ALUSrc, 
            ALUSrcA    => ALUSrcA,
            ImmSrc     => open,       
            RegWrite   => RegWrite,
            Jump       => Jump,
            JalrMux    => JalrMux,
            Branch     => Branch
        );

    -- 5. Register File
    u_RegFile: entity work.register_file
        port map(
            clk        => clk,
            rst        => reset,
            reg_write  => RegWrite,
            rs1_addr   => Instr(19 downto 15),
            rs2_addr   => Instr(24 downto 20),
            rd_addr    => Instr(11 downto 7),
            write_data => Result,
            rs1_data   => RD1,                 
            rs2_data   => RD2                  
        );

    -- 6. Sign Extender
    u_Extend: entity work.sign_extender
        port map(
            inst      => Instr,  
            immediate => ImmExt  
        );

    -- 7. Branch Unit
    u_BranchUnit: entity work.branch_unit
        port map(
            pc_current    => PC,
            immediate     => ImmExt,
            rs1_data      => RD1,                 
            rs2_data      => RD2,                 
            branch_en     => Branch,           
            funct3        => Instr(14 downto 12), 
            branch_target => PCTarget,            
            pc_src        => BranchTaken                
        );

    -- 8. ALU Source MUXes
    -- SrcA MUX: Selects between RD1 and PC (for AUIPC)
    SrcA <= PC when ALUSrcA = '1' else RD1;

    -- SrcB MUX: Selects between RD2 and ImmExt
    u_ALUMUX: entity work.ALU_MUX
        port map(d0 => RD2, d1 => ImmExt, s => ALUSrc, y => SrcB);

    -- 9. ALU
    u_ALU: entity work.alu
        port map(
            a          => SrcA,         
            b          => SrcB,        
            alu_op     => ALUControl,  
            alu_result => ALUResult, 
            zero       => Zero         
        );

    -- 10. Data Memory (with sub-word support)
    u_DataMem: entity work.data_memory
        port map(
            clk        => clk,
            mem_write  => MemWrite,
            funct3     => Instr(14 downto 12),
            addr       => ALUResult,  
            write_data => RD2,        
            read_data  => ReadData    
        );

    -- ==========================================
    -- 4. FINAL RESULT MUX (Writeback)
    -- ==========================================
    -- "00": ALUResult, "01": ReadData, "10": PCPlus4 (JAL/JALR), "11": ImmExt (LUI)
    with ResultSrc select
        Result <= ALUResult when "00",
                  ReadData  when "01",
                  PCPlus4   when "10",
                  ImmExt    when "11",
                  ALUResult when others;

    out_pc     <= PC;
    out_result <= Result;
end Structural;
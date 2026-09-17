library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity branch_unit is
    port (
        -- Data Inputs
        pc_current    : in  std_logic_vector(31 downto 0); -- Current PC
        immediate     : in  std_logic_vector(31 downto 0); -- From Sign Extender
        rs1_data      : in  std_logic_vector(31 downto 0); -- From Register File
        rs2_data      : in  std_logic_vector(31 downto 0); -- From Register File
        
        -- Control Signals (from Decoder)
        branch_en     : in  std_logic;                    -- Is this a branch instruction?
        funct3        : in  std_logic_vector(2 downto 0); -- Specific branch type (BEQ, BNE, etc.)
        
        -- Outputs
        branch_target : out std_logic_vector(31 downto 0); -- Calculated jump address
        pc_src        : out std_logic                     -- 0: PC+4, 1: Branch Target
    );
end branch_unit;

architecture behavioral of branch_unit is
    signal take_branch : std_logic;
begin
    -- 1. Calculate Target Address: PC + Immediate
    branch_target <= std_logic_vector(unsigned(pc_current) + unsigned(immediate));

    -- 2. Decision Logic based on funct3 (RISC-V Standard)
    process(branch_en, funct3, rs1_data, rs2_data)
    begin
        take_branch <= '0';
        if branch_en = '1' then
            case funct3 is
                when "000" => -- BEQ (Branch if Equal)
                    if rs1_data = rs2_data then take_branch <= '1'; end if;
                when "001" => -- BNE (Branch if Not Equal)
                    if rs1_data /= rs2_data then take_branch <= '1'; end if;
                when "100" => -- BLT (Branch if Less Than - Signed)
                    if signed(rs1_data) < signed(rs2_data) then take_branch <= '1'; end if;
                when "101" => -- BGE (Branch if Greater or Equal - Signed)
                    if signed(rs1_data) >= signed(rs2_data) then take_branch <= '1'; end if;
                when "110" => -- BLTU (Branch if Less Than - Unsigned)
                    if unsigned(rs1_data) < unsigned(rs2_data) then take_branch <= '1'; end if;
                when "111" => -- BGEU (Branch if Greater or Equal - Unsigned)
                    if unsigned(rs1_data) >= unsigned(rs2_data) then take_branch <= '1'; end if;
                when others => take_branch <= '0';
            end case;
        end if;
    end process;

    -- Output to the PC MUX
    pc_src <= take_branch;

end behavioral;
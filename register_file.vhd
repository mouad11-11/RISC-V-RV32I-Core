library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        reg_write: in  std_logic;                     -- Write enable from Decoder
        rs1_addr : in  std_logic_vector(4 downto 0);  -- Source register 1
        rs2_addr : in  std_logic_vector(4 downto 0);  -- Source register 2
        rd_addr  : in  std_logic_vector(4 downto 0);  -- Destination register
        write_data: in std_logic_vector(31 downto 0); -- Data from Write-back MUX
        rs1_data : out std_logic_vector(31 downto 0); -- Output to ALU/Branch
        rs2_data : out std_logic_vector(31 downto 0)  -- Output to ALU/Mem/Branch
    );
end register_file;

architecture behavioral of register_file is
    -- Define the 32x32 register array
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));

begin
    -- Asynchronous Read Logic (Outputs change instantly when addresses change)
    -- Logic for rs1: returns 0 if address is 0, otherwise returns register value
    rs1_data <= (others => '0') when (rs1_addr = "00000") else 
                regs(to_integer(unsigned(rs1_addr)));
                
    -- Logic for rs2: returns 0 if address is 0, otherwise returns register value
    rs2_data <= (others => '0') when (rs2_addr = "00000") else 
                regs(to_integer(unsigned(rs2_addr)));

    -- Synchronous Write Logic
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regs <= (others => (others => '0'));
            elsif reg_write = '1' then
                -- Guard to ensure x0 is never overwritten
                if rd_addr /= "00000" then
                    regs(to_integer(unsigned(rd_addr))) <= write_data;
                end if;
            end if;
        end if;
    end process;

end behavioral;
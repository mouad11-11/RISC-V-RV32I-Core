library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc is
    Port ( 
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        pc_next : in  STD_LOGIC_VECTOR(31 downto 0);
        pc_out  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end pc;

architecture Behavioral of pc is

    -- THIS IS THE MISSING LINE! 
    -- We declare the internal signal here before the 'begin'
    signal pc_current : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            pc_current <= (others => '0'); -- Reset to address 0
        elsif rising_edge(clk) then
            pc_current <= pc_next;         -- Update on clock edge
        end if;
    end process;

    -- Connect the internal signal to the output port
    pc_out <= pc_current;

end Behavioral;
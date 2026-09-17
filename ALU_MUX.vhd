library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_MUX is
    Port ( 
        d0 : in  STD_LOGIC_VECTOR (31 downto 0); -- Input 0 (From Register File RD2)
        d1 : in  STD_LOGIC_VECTOR (31 downto 0); -- Input 1 (From Sign Extender)
        s  : in  STD_LOGIC;                      -- Select signal (ALUSrc from Control Unit)
        y  : out STD_LOGIC_VECTOR (31 downto 0)  -- Output (To ALU SrcB)
    );
end ALU_MUX;

architecture Behavioral of ALU_MUX is
begin

    -- If the select line (s) is '1', output d1. Otherwise, output d0.
    y <= d1 when s = '1' else d0;

end Behavioral;
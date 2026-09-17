library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Required to do math (+) on vectors

entity ADD4 is 
    Port ( a : in  STD_LOGIC_VECTOR(31 downto 0);
           y : out STD_LOGIC_VECTOR(31 downto 0));
end ADD4;

architecture Behavioral of ADD4 is 
begin
    -- Converts vector to an unsigned number, adds 4, and converts back to a vector
    y <= std_logic_vector(unsigned(a) + 4);
end Behavioral;
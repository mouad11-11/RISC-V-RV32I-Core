library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extender is
    port (
        inst      : in  std_logic_vector(31 downto 0); -- Raw 32-bit instruction
        immediate : out std_logic_vector(31 downto 0)  -- Reconstructed 32-bit value
    );
end sign_extender;

architecture behavioral of sign_extender is
    signal opcode : std_logic_vector(6 downto 0);
begin
    opcode <= inst(6 downto 0);

    process(inst, opcode)
    begin
        case opcode is
            -- I-type (addi, lw, jalr)
            when "0010011" | "0000011" | "1100111" =>
                immediate <= (31 downto 12 => inst(31)) & inst(31 downto 20);

            -- S-type (sw)
            when "0100011" =>
                immediate <= (31 downto 12 => inst(31)) & inst(31 downto 25) & inst(11 downto 7);

            -- B-type (beq, bne)
            when "1100011" =>
                immediate <= (31 downto 12 => inst(31)) & inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0';

            -- U-type (lui, auipc)
            when "0110111" | "0010111" =>
                immediate <= inst(31 downto 12) & x"000";

            -- J-type (jal)
            when "1101111" =>
                immediate <= (31 downto 20 => inst(31)) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0';

            when others =>
                immediate <= (others => '0');
        end case;
    end process;
end behavioral;
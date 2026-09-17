library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port (
        a          : in  std_logic_vector(31 downto 0);
        b          : in  std_logic_vector(31 downto 0);
        alu_op     : in  std_logic_vector(3 downto 0); -- 4-bit ALU control for full RV32I
        alu_result : out std_logic_vector(31 downto 0);
        zero       : out std_logic                     
    );
end alu;

architecture behavioral of alu is
begin
    process(a, b, alu_op)
        variable res   : std_logic_vector(31 downto 0);
        variable shamt : integer range 0 to 31;
    begin
        shamt := to_integer(unsigned(b(4 downto 0)));
        case alu_op is
            when "0000" => -- ADD
                res := std_logic_vector(unsigned(a) + unsigned(b));
            when "0001" => -- SUB
                res := std_logic_vector(unsigned(a) - unsigned(b));
            when "0010" => -- SLL (Shift Left Logical)
                res := std_logic_vector(shift_left(unsigned(a), shamt));
            when "0011" => -- SLT (Set Less Than - Signed)
                if signed(a) < signed(b) then
                    res := x"00000001";
                else
                    res := x"00000000";
                end if;
            when "0100" => -- SLTU (Set Less Than - Unsigned)
                if unsigned(a) < unsigned(b) then
                    res := x"00000001";
                else
                    res := x"00000000";
                end if;
            when "0101" => -- XOR
                res := a xor b;
            when "0110" => -- SRL (Shift Right Logical)
                res := std_logic_vector(shift_right(unsigned(a), shamt));
            when "0111" => -- SRA (Shift Right Arithmetic)
                res := std_logic_vector(shift_right(signed(a), shamt));
            when "1000" => -- OR
                res := a or b;
            when "1001" => -- AND
                res := a and b;
            when "1010" => -- PASS_B (for LUI)
                res := b;
            when others => 
                res := (others => '0');
        end case;
        
        alu_result <= res;
        
        -- Zero flag for equality checks
        if res = x"00000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;
end behavioral;
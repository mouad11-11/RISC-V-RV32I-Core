library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    port (
        clk        : in  std_logic;
        mem_write  : in  std_logic;                     -- From Decoder
        funct3     : in  std_logic_vector(2 downto 0);  -- For sub-word memory access (LB, LH, LW, SB, SH, SW)
        addr       : in  std_logic_vector(31 downto 0); -- From ALU Result
        write_data : in  std_logic_vector(31 downto 0); -- From rs2_data
        read_data  : out std_logic_vector(31 downto 0)  -- To Write-back MUX
    );
end data_memory;

architecture behavioral of data_memory is
    -- Define memory size (64 words / 256 bytes)
    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    
    signal word_idx  : integer range 0 to 63;
    signal byte_idx  : integer range 0 to 3;
    signal raw_word  : std_logic_vector(31 downto 0);
begin
    -- Bound to valid range (0 to 63) to prevent simulation index out-of-bounds error
    word_idx <= to_integer(unsigned(addr(7 downto 2)));
    byte_idx <= to_integer(unsigned(addr(1 downto 0)));
    raw_word <= ram(word_idx);

    -- Synchronous Write: Data is stored on the rising edge of the clock
    process(clk)
        variable current_word : std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if mem_write = '1' then
                current_word := ram(word_idx);
                case funct3 is
                    when "000" => -- SB (Store Byte)
                        case byte_idx is
                            when 0 => current_word(7 downto 0)   := write_data(7 downto 0);
                            when 1 => current_word(15 downto 8)  := write_data(7 downto 0);
                            when 2 => current_word(23 downto 16) := write_data(7 downto 0);
                            when 3 => current_word(31 downto 24) := write_data(7 downto 0);
                        end case;
                        ram(word_idx) <= current_word;

                    when "001" => -- SH (Store Halfword)
                        if addr(1) = '0' then
                            current_word(15 downto 0)  := write_data(15 downto 0);
                        else
                            current_word(31 downto 16) := write_data(15 downto 0);
                        end if;
                        ram(word_idx) <= current_word;

                    when others => -- SW (Store Word - default)
                        ram(word_idx) <= write_data;
                end case;
            end if;
        end if;
    end process;

    -- Asynchronous Read with Sub-Word Handling (LB, LH, LW, LBU, LHU)
    process(raw_word, funct3, byte_idx, addr)
        variable selected_byte : std_logic_vector(7 downto 0);
        variable selected_half : std_logic_vector(15 downto 0);
    begin
        -- Extract byte
        case byte_idx is
            when 0 => selected_byte := raw_word(7 downto 0);
            when 1 => selected_byte := raw_word(15 downto 8);
            when 2 => selected_byte := raw_word(23 downto 16);
            when 3 => selected_byte := raw_word(31 downto 24);
        end case;

        -- Extract halfword
        if addr(1) = '0' then
            selected_half := raw_word(15 downto 0);
        else
            selected_half := raw_word(31 downto 16);
        end if;

        case funct3 is
            when "000" => -- LB (Load Byte - Signed)
                read_data <= (31 downto 8 => selected_byte(7)) & selected_byte;
            when "001" => -- LH (Load Halfword - Signed)
                read_data <= (31 downto 16 => selected_half(15)) & selected_half;
            when "100" => -- LBU (Load Byte - Unsigned)
                read_data <= x"000000" & selected_byte;
            when "101" => -- LHU (Load Halfword - Unsigned)
                read_data <= x"0000" & selected_half;
            when others => -- LW (Load Word)
                read_data <= raw_word;
        end case;
    end process;

end behavioral;
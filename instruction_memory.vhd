library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    port (
        pc   : in  std_logic_vector(31 downto 0); -- From PC output
        inst : out std_logic_vector(31 downto 0)  -- To Decoder/RegFile/SignExt
    );
end instruction_memory;

architecture behavioral of instruction_memory is
    type mem_array is array (0 to 63) of std_logic_vector(31 downto 0);
    
    -- Address Table for different operations:
    signal rom : mem_array := (
        -- Index 0 (PC=0):  addi x1, x0, 5      -> x1 = 5
        0      => x"00500093", 
        
        -- Index 1 (PC=4):  addi x2, x0, 10     -> x2 = 10
        1      => x"00A00113",
        
        -- Index 2 (PC=8):  add x3, x1, x2      -> x3 = 5 + 10 = 15
        2      => x"002081B3",
        
        -- Index 3 (PC=12): sub x4, x3, x1      -> x4 = 15 - 5 = 10
        3      => x"40118233",
        
        -- Index 4 (PC=16): and x5, x1, x2      -> x5 = 5 & 10 = 0
        4      => x"0020F2B3",
        
        -- Index 5 (PC=20): or x6, x1, x2       -> x6 = 5 | 10 = 15
        5      => x"0020E333",

        -- Index 6 (PC=24): xor x7, x1, x2      -> x7 = 5 ^ 10 = 15
        6      => x"0020C3B3",

        -- Index 7 (PC=28): sll x8, x1, x1      -> x8 = 5 << 5 = 160
        7      => x"00109433",

        -- Index 8 (PC=32): srl x9, x8, x1      -> x9 = 160 >> 5 = 5
        8      => x"001454B3",

        -- Index 9 (PC=36): slt x10, x1, x2     -> x10 = (5 < 10) = 1
        9      => x"0020A533",

        -- Index 10 (PC=40): sltu x11, x2, x1   -> x11 = (10 < 5) = 0
        10     => x"001135B3",

        -- Index 11 (PC=44): lui x12, 0x12345   -> x12 = 0x12345000
        11     => x"12345637",

        -- Index 12 (PC=48): auipc x13, 0x1000  -> x13 = 48 + 0x01000000 = 0x01000030
        12     => x"01000697",
        
        -- Index 13 (PC=52): sw x3, 4(x0)       -> Store x3 (15) at byte address 4
        13     => x"00302223",

        -- Index 14 (PC=56): sb x1, 8(x0)       -> Store byte x1 (5) at byte address 8
        14     => x"00100423",
        
        -- Index 15 (PC=60): lw x14, 4(x0)      -> Load word from byte 4 -> x14 = 15
        15     => x"00402703",

        -- Index 16 (PC=64): lb x15, 8(x0)      -> Load byte from byte 8 -> x15 = 5
        16     => x"00800783",

        -- Index 17 (PC=68): jal x16, 8         -> Jump to PC=76 (Index 19), x16 = 72
        17     => x"0080086F",

        -- Index 18 (PC=72): addi x17, x0, 99   -> (Skipped by JAL!)
        18     => x"06300893",

        -- Index 19 (PC=76): bne x1, x2, 8      -> Jump to PC=84 (Index 21)
        19     => x"00209463",

        -- Index 20 (PC=80): addi x18, x0, 88   -> (Skipped by BNE!)
        20     => x"05800913",

        -- Index 21 (PC=84): addi x19, x0, 42   -> Marker reached: x19 = 42
        21     => x"02A00993",

        -- Index 22 (PC=88): jalr x0, 0(x16)    -> Return to index 18 (PC=72)
        22     => x"00080067",

        others => x"00000013" -- NOP (addi x0, x0, 0)
    );

begin
    -- Divide PC by 4 to map byte-addressing to word-indexing
    -- Mask to 6 bits (pc(7 downto 2)) to prevent simulation index out-of-bounds error
    inst <= rom(to_integer(unsigned(pc(7 downto 2))));
    
end behavioral;
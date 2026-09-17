library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_riscv_top is
end tb_riscv_top;

architecture Behavioral of tb_riscv_top is

    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';
    signal out_pc     : STD_LOGIC_VECTOR(31 downto 0);
    signal out_result : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    -- Test Vector definition for automated verification
    type test_record is record
        expected_pc   : integer;
        expected_res  : integer;
        has_res_check : boolean;
    end record;

    type test_array is array (1 to 20) of test_record;
    constant TEST_VECTORS : test_array := (
        1  => (8,   15,        true),
        2  => (12,  10,        true),
        3  => (16,  0,         true),
        4  => (20,  15,        true),
        5  => (24,  15,        true),
        6  => (28,  160,       true),
        7  => (32,  5,         true),
        8  => (36,  1,         true),
        9  => (40,  0,         true),
        10 => (44,  305418240, true),
        11 => (48,  16777264,  true),
        12 => (52,  0,         false),
        13 => (56,  0,         false),
        14 => (60,  15,        true),
        15 => (64,  5,         true),
        16 => (68,  72,        true),
        17 => (76,  0,         false),
        18 => (84,  42,        true),
        19 => (88,  92,        true),
        20 => (72,  99,        true)
    );

begin

    -- Instantiate Device Under Test
    UUT: entity work.riscv_top
        port map (
            clk        => clk,
            reset      => reset,
            out_pc     => out_pc,
            out_result => out_result
        );

    -- 100 MHz Clock Generator
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus and Self-Checking Verification Process
    stim_proc: process
    begin
        report "================================================================" severity note;
        report "Starting RISC-V RV32I Self-Checking Hardware Verification" severity note;
        report "================================================================" severity note;

        -- Apply reset
        reset <= '1';
        wait for 25 ns;
        reset <= '0';
        wait for 1 ns;

        -- Step through cycles and assert expected values
        for cycle in 1 to 20 loop
            wait until rising_edge(clk);
            wait for 1 ns;

            -- 1. Assert Program Counter
            assert to_integer(unsigned(out_pc)) = TEST_VECTORS(cycle).expected_pc
                report "ASSERTION FAILED at Cycle " & integer'image(cycle) & 
                       ": PC mismatch! Expected " & integer'image(TEST_VECTORS(cycle).expected_pc) &
                       ", got " & integer'image(to_integer(unsigned(out_pc)))
                severity failure;

            -- 2. Assert Result
            if TEST_VECTORS(cycle).has_res_check then
                assert to_integer(signed(out_result)) = TEST_VECTORS(cycle).expected_res
                    report "ASSERTION FAILED at Cycle " & integer'image(cycle) & 
                           ": Result mismatch! Expected " & integer'image(TEST_VECTORS(cycle).expected_res) &
                           ", got " & integer'image(to_integer(signed(out_result)))
                    severity failure;
            end if;

            report "Cycle " & integer'image(cycle) & 
                   " | PC = " & integer'image(to_integer(unsigned(out_pc))) & 
                   " | Result = " & integer'image(to_integer(signed(out_result))) &
                   " | PASS" severity note;
        end loop;

        report "================================================================" severity note;
        report "ALL 20 HARDWARE ASSERTIONS PASSED SUCCESSFULLY!" severity note;
        report "================================================================" severity note;
        wait;
    end process;

end Behavioral;
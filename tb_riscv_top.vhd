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

    -- Stimulus and Verification Process
    stim_proc: process
    begin
        report "================================================================" severity note;
        report "Starting RISC-V RV32I Processor Hardware Simulation" severity note;
        report "================================================================" severity note;

        -- Apply reset
        reset <= '1';
        wait for 25 ns;
        reset <= '0';
        wait for 1 ns;

        -- Step through cycles and log trace
        for cycle in 1 to 24 loop
            wait until rising_edge(clk);
            wait for 1 ns;
            report "Cycle " & integer'image(cycle) & 
                   " | PC = " & integer'image(to_integer(unsigned(out_pc))) & 
                   " | Result = " & integer'image(to_integer(signed(out_result))) severity note;
        end loop;

        report "================================================================" severity note;
        report "Simulation Completed Successfully!" severity note;
        report "================================================================" severity note;
        wait;
    end process;

end Behavioral;
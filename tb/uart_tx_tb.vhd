library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_tb is
end uart_tx_tb;

architecture behavior of uart_tx_tb is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal tx_start : std_logic := '0';
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal tx       : std_logic;
    signal tx_busy  : std_logic;

begin

    uut: entity work.uart_tx
        port map (
            clk      => clk,
            rst      => rst,
            tx_start => tx_start,
            data_in  => data_in,
            tx       => tx,
            tx_busy  => tx_busy
        );

    ------------------------------------------------
    -- Clock generation (50 MHz)
    ------------------------------------------------

    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    ------------------------------------------------
    -- Stimulus
    ------------------------------------------------

    stim_proc : process
    begin

        -- reset
        wait for 100 ns;
        rst <= '0';

        wait for 1 us;

        -- send byte
        data_in <= x"A5";
        tx_start <= '1';

        wait for 20 ns;
        tx_start <= '0';

        -- allow transmission to finish
        wait for 200 us;

        assert false report "Simulation Finished" severity failure;

    end process;

end behavior;
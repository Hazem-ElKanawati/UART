library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
end uart_rx_tb;

architecture behavior of uart_rx_tb is

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';
    signal rx         : std_logic := '1';
    signal data_out   : std_logic_vector(7 downto 0);
    signal data_ready : std_logic;

    constant BIT_TIME : time := 10 us; -- 100k baud

begin

    uut: entity work.uart_rx
        port map (
            clk        => clk,
            rst        => rst,
            rx         => rx,
            data_out   => data_out,
            data_ready => data_ready
        );

    -- clock generation (50MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- stimulus process
    stim_proc : process
    begin

        -- reset
        wait for 100 ns;
        rst <= '0';

        wait for 1 us;

        -- start bit
        rx <= '0';
        wait for BIT_TIME;

        -- send 0xA5 = 10100101 (LSB first)
        rx <= '1'; wait for BIT_TIME;
        rx <= '0'; wait for BIT_TIME;
        rx <= '1'; wait for BIT_TIME;
        rx <= '0'; wait for BIT_TIME;
        rx <= '0'; wait for BIT_TIME;
        rx <= '1'; wait for BIT_TIME;
        rx <= '0'; wait for BIT_TIME;
        rx <= '1'; wait for BIT_TIME;

        -- stop bit
        rx <= '1';
        wait for BIT_TIME;

        wait for 200 us;

        assert false report "Simulation Finished" severity failure;

    end process;

end behavior;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture sim of uart_rx_tb is

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal rx  : std_logic := '1';
signal data_out : std_logic_vector(7 downto 0);

begin

dut: entity work.uart_rx
port map(
    clk => clk,
    rx => rx,
	 rst => rst,
    data_out => data_out
);

clk_process : process
begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
end process;

stim_proc: process
begin

wait for 100 ns;

rx <= '0';
wait for 104 us;

rx <= '1';
wait for 104 us;

rx <= '0';
wait for 104 us;

rx <= '1';
wait for 104 us;

rx <= '0';
wait for 104 us;

rx <= '1';
wait for 104 us;

rx <= '0';
wait for 104 us;

rx <= '1';
wait for 104 us;

rx <= '0';
wait for 104 us;

rx <= '1';
wait for 104 us;

wait;

end process;

end sim;
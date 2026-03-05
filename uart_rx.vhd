library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        rx         : in  STD_LOGIC;
        data_out   : out STD_LOGIC_VECTOR(7 downto 0);
        data_ready : out STD_LOGIC
    );
end uart_rx;

architecture Behavioral of uart_rx is

    constant BAUD_DIV  : integer := 500;
    constant HALF_BAUD : integer := 250;

    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;

    signal rx_sync_0 : STD_LOGIC := '1';
    signal rx_sync_1 : STD_LOGIC := '1';
    signal rx_clean  : STD_LOGIC;

    signal baud_counter : integer range 0 to BAUD_DIV := 0;
    signal bit_index    : integer range 0 to 7 := 0;

    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

    rx_clean <= rx_sync_1;

    process(clk)
    begin
        if rising_edge(clk) then
            rx_sync_0 <= rx;
            rx_sync_1 <= rx_sync_0;
        end if;
    end process;


    process(clk, rst)
    begin
        if rst = '1' then

            state <= IDLE;
            baud_counter <= 0;
            bit_index <= 0;
            shift_reg <= (others => '0');
            data_out <= (others => '0');
            data_ready <= '0';

        elsif rising_edge(clk) then

            data_ready <= '0';

            case state is

                when IDLE =>

                    baud_counter <= 0;
                    bit_index <= 0;

                    if rx_clean = '0' then
                        state <= START;
                    end if;


                when START =>

                    if baud_counter = HALF_BAUD - 1 then
                        baud_counter <= 0;

                        if rx_clean = '0' then
                            state <= DATA;
                        else
                            state <= IDLE;
                        end if;

                    else
                        baud_counter <= baud_counter + 1;
                    end if;


                when DATA =>

                    if baud_counter = BAUD_DIV - 1 then
                        baud_counter <= 0;

                        shift_reg(bit_index) <= rx_clean;
                        bit_index <= bit_index + 1;

                        if bit_index = 7 then
                            state <= STOP;
                        end if;

                    else
                        baud_counter <= baud_counter + 1;
                    end if;


                when STOP =>

                    if baud_counter = BAUD_DIV - 1 then
                        baud_counter <= 0;

                        if rx_clean = '1' then
                            data_out <= shift_reg;
                            data_ready <= '1';
                        end if;

                        state <= IDLE;

                    else
                        baud_counter <= baud_counter + 1;
                    end if;

            end case;

        end if;
    end process;

end Behavioral;
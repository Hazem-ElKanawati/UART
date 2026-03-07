library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        tx_start  : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(7 downto 0);
        tx        : out STD_LOGIC;
        tx_busy   : out STD_LOGIC
    );
end uart_tx;

architecture Behavioral of uart_tx is

    constant BAUD_DIV : integer := 500;

    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;

    signal baud_counter : integer range 0 to BAUD_DIV := 0;
    signal bit_index    : integer range 0 to 7 := 0;

    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    signal tx_reg : STD_LOGIC := '1';

begin

    tx <= tx_reg;

    process(clk, rst)
    begin
        if rst = '1' then

            state        <= IDLE;
            baud_counter <= 0;
            bit_index    <= 0;
            shift_reg    <= (others => '0');
            tx_reg       <= '1';
            tx_busy      <= '0';

        elsif rising_edge(clk) then

            case state is


                when IDLE =>

                    tx_reg  <= '1';
                    tx_busy <= '0';
                    baud_counter <= 0;
                    bit_index <= 0;

                    if tx_start = '1' then
                        shift_reg <= data_in;
                        tx_busy <= '1';
                        state <= START;
                    end if;

                when START =>

                    tx_reg <= '0';

                    if baud_counter = BAUD_DIV - 1 then
                        baud_counter <= 0;
                        state <= DATA;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;


                when DATA =>

                    tx_reg <= shift_reg(bit_index);

                    if baud_counter = BAUD_DIV - 1 then
                        baud_counter <= 0;

                        if bit_index = 7 then
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                        end if;

                    else
                        baud_counter <= baud_counter + 1;
                    end if;


                when STOP =>

                    tx_reg <= '1';

                    if baud_counter = BAUD_DIV - 1 then
                        baud_counter <= 0;
                        state <= IDLE;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;

            end case;

        end if;
    end process;

end Behavioral;
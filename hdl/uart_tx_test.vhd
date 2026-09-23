library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_test is
    generic (
        SIM_DIV_LIMIT : integer := 5 -- Для симуляции быстро, для платы можно увеличить
    );
    port (
        clk     : in  std_logic;  -- Тактовый генератор платы
        tx_uart : out std_logic   -- UART TX линия (на пин M11)
    );
end entity uart_tx_test;

architecture rtl of uart_tx_test is
    -- Таймер для смены бегущего огня
    signal clk_div_reg : integer range 0 to SIM_DIV_LIMIT := 0;
    signal tick        : std_logic := '0';
    signal shift_reg   : std_logic_vector(4 downto 0) := "00001";
    signal current_val : std_logic_vector(7 downto 0) := x"31"; -- ASCII '1'

    -- Состояния UART передатчика
    type uart_state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal uart_state  : uart_state_type := IDLE;
    
    -- Делитель частоты для бодрейта UART (115200 при 27МГц -> примерно 234 такта на бит)
    -- Для быстрой симуляции поставим меньше, например, 2 такта на бит
    constant UART_BAUD_DIV_MAX : integer := 4; 
    signal baud_counter : integer range 0 to UART_BAUD_DIV_MAX := 0;
    signal bit_index    : integer range 0 to 7 := 0;
    signal tx_shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_reg       : std_logic := '1';

begin

    -- 1. Процесс формирования бегущего числа
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_div_reg = SIM_DIV_LIMIT - 1 then
                clk_div_reg <= 0;
                tick <= '1';
                -- Сдвиг единицы
                shift_reg <= shift_reg(3 downto 0) & shift_reg(4);
            else
                clk_div_reg <= clk_div_reg + 1;
                tick <= '0';
            end if;
        end if;
    end process;

    -- Превращаем позицию бита в ASCII символ ('1', '2', '3', '4', '5') для отправки в UART
    process(shift_reg)
    begin
        case shift_reg is
            when "00001" => current_val <= x"31"; -- '1'
            when "00010" => current_val <= x"32"; -- '2'
            when "00100" => current_val <= x"33"; -- '3'
            when "01000" => current_val <= x"34"; -- '4'
            when "10000" => current_val <= x"35"; -- '5'
            when others  => current_val <= x"30"; -- '0'
        end case;
    end process;

    -- 2. Конечный автомат UART TX (отправка пакета при каждом tick)
    process(clk)
    begin
        if rising_edge(clk) then
            case uart_state is
                when IDLE =>
                    tx_reg <= '1'; -- Линия свободна (High)
                    if tick = '1' then
                        tx_shift_reg <= current_val;
                        uart_state <= START_BIT;
                        baud_counter <= 0;
                    end if;

                when START_BIT =>
                    tx_reg <= '0'; -- Стартовый бит (Low)
                    if baud_counter = UART_BAUD_DIV_MAX - 1 then
                        baud_counter <= 0;
                        bit_index <= 0;
                        uart_state <= DATA_BITS;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;

                when DATA_BITS =>
                    tx_reg <= tx_shift_reg(bit_index); -- Передача битов данных
                    if baud_counter = UART_BAUD_DIV_MAX - 1 then
                        baud_counter <= 0;
                        if bit_index = 7 then
                            uart_state <= STOP_BIT;
                        else
                            bit_index <= bit_index + 1;
                        end if;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;

                when STOP_BIT =>
                    tx_reg <= '1'; -- Стоповый бит (High)
                    if baud_counter = UART_BAUD_DIV_MAX - 1 then
                        baud_counter <= 0;
                        uart_state <= IDLE;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;
            end case;
        end if;
    end process;

    tx_uart <= tx_reg;

end architecture rtl;
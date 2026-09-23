library ieee;
use ieee.std_logic_1164.all;

entity uart_tx_test_tb is
end entity uart_tx_test_tb;

architecture sim of uart_tx_test_tb is
    signal clk     : std_logic := '0';
    signal tx_uart : std_logic;
begin
    -- Генерация тактовой частоты (~27 МГц)
    clk <= not clk after 18.5 ns;

    -- Инстанцирование тестируемого модуля
    dut: entity work.uart_tx_test
        port map (
            clk     => clk,
            tx_uart => tx_uart
        );

end architecture sim;
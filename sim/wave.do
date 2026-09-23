# Добавление сигналов на временную диаграмму
add wave -noupdate -label "Clock (27MHz)" /uart_tx_test_tb/clk
add wave -noupdate -label "UART TX Output" /uart_tx_test_tb/tx_uart
add wave -noupdate -label "Shift Register" -radix binary /uart_tx_test_tb/dut/shift_reg

# Настройка масштаба отображения
configure wave -namecolwidth 180
configure wave -valuecolwidth 100
tree update
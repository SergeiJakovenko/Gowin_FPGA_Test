Set-Location "C:\Gowin_FPGA_Test"
Write-Host "Заполнение проекта файлами..." -ForegroundColor Cyan

# 1. VHDL Код (hdl/top_led_button.vhd)
$hdlCode = @'
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_led_button is
    port (
        clk     : in  std_logic;
        rx_uart : in  std_logic;
        tx_uart : out std_logic;
        led     : out std_logic_vector(5 downto 0);
        btn     : in  std_logic_vector(4 downto 0)
    );
end entity top_led_button;

architecture rtl of top_led_button is
begin
    -- Вывод состояния кнопок на светодиоды (инверсно)
    led(4 downto 0) <= not btn(4 downto 0);
    led(5) <= '1'; -- Индикатор питания/готовности
    tx_uart <= rx_uart;
end architecture rtl;
'
Set-Content -Path "hdl/top_led_button.vhd" -Value $hdlCode
'@

# 2. Тестбенч (sim/top_led_button_tb.vhd)
$tbCode = @'
library ieee;
use ieee.std_logic_1164.all;

entity top_led_button_tb is
end entity top_led_button_tb;

architecture sim of top_led_button_tb is
    signal clk     : std_logic := '0';
    signal rx_uart : std_logic := '1';
    signal tx_uart : std_logic;
    signal led     : std_logic_vector(5 downto 0);
    signal btn     : std_logic_vector(4 downto 0) := "11111";
begin
    clk <= not clk after 10 ns;

    dut: entity work.top_led_button
        port map (clk => clk, rx_uart => rx_uart, tx_uart => tx_uart, led => led, btn => btn);

    process
    begin
        wait for 50 ns;
        btn(0) <= '0'; -- Нажатие кнопки
        wait for 100 ns;
        btn(0) <= '1';
        wait;
    end process;
end architecture sim;
'
Set-Content -Path "sim/top_led_button_tb.vhd" -Value $tbCode
'@


# 3. Python Сервер (server/app.py)
$serverCode = @'
import serial
from flask import Flask, render_template, request, jsonify

app = Flask(__name__, template_folder='../web', static_folder='../web')

PORT = "COM5"
BAUD = 115200

try:
    ser = serial.Serial(PORT, BAUD, timeout=1)
    print(f"COM порт {PORT открыт успешно.")
except:
    ser = None
    print(f"Предупреждение: Не удалось открыть {PORT}. Работаем в офлайн режиме.")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/toggle', methods=['POST'])
def toggle():
    data = request.json
    state = data.get('state', 0)
    if ser and ser.is_open:
        ser.write(b'1' if state else b'0')
    return jsonify({"status": "success", "state": state})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
'
Set-Content -Path "server/app.py" -Value $serverCode
'@

# 4. Веб-страница (web/index.html)
$webCode = @'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Tank Primer Control</title>
    <style>
        body { font-family: sans-serif; text-align: center; background: #121212; color: #fff; margin-top: 50px; }
        button { padding: 15px 30px; font-size: 18px; background: #007acc; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #005999; }
    </style>
</head>
<body>
    <h1>Управление Tank Primer 20K</h1>
    <button onclick="toggleLed()">Переключить LED</button>
    <script>
        let state = 0;
        function toggleLed() {
            state = state === 1 ? 0 : 1;
            fetch('/api/toggle', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({state: state})
            });
        }
    </script>
</body>
</html>
'
Set-Content -Path "web/index.html" -Value $webCode

Write-Host "Все файлы успешно записаны в структуру проекта!" -ForegroundColor Green
'@
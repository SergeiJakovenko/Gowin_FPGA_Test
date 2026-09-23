# Скрипт компиляции и симуляции для задачи: Процесс TX тест (uart_tx_test)
Write-Host "=== Запуск компиляции uart_tx_test ===" -ForegroundColor Cyan

# Возвращаемся в корень проекта, если запуск идет из папки scripts
$currentDir = Get-Location
if ($currentDir.Path -like "*scripts") {
    Set-Location ".."
}

# 1. Очистка старого кэша компиляции ModelSim для предотвращения багов со старыми файлами
if (Test-Path "work") {
    Write-Host "Очистка папки work..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "work"
}

# 2. Создание рабочей библиотеки ModelSim
vlib work
vcom -2008 hdl/uart_tx_test.vhd
vcom -2008 sim/uart_tx_test_tb.vhd


# 3. Запуск симуляции в консольном режиме с ограничением до 100мс
Write-Host "Запуск симуляции на 100 мс в ModelSim..." -ForegroundColor Green
vsim -c uart_tx_test_tb -do "run 100 ms; exit"

Write-Host "Симуляция успешно завершена! Временная диаграмма ограничена 100 мс." -ForegroundColor Cyan
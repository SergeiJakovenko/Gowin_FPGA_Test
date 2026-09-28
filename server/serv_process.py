import asyncio
import os
import serial
import websockets

COM_PORT = 'COM4'
BAUD_RATE = 115200
WS_HOST = 'localhost'
WS_PORT = 8765

connected_clients = set()
last_val = None
ser = None  # Глобальная ссылка на порт для корректного закрытия

def uart_reader_thread(loop):
    global last_val, ser
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=None)
        print(f"[UART] Порт {COM_PORT} успешно открыт ({BAUD_RATE} baud)")
    except Exception as e:
        print(f"[UART ERROR] Ошибка открытия порта {COM_PORT}: {e}")
        return

    while True:
        try:
            if ser and ser.is_open:
                raw_data = ser.read(1)
                if raw_data:
                    val = raw_data.decode('utf-8', errors='ignore')
                    if val != last_val:
                        last_val = val
                        print(f"[FPGA -> SERVER]: {val}")
                        for ws in list(connected_clients):
                            asyncio.run_coroutine_threadsafe(ws.send(val), loop)
        except Exception:
            break

async def ws_handler(websocket):
    connected_clients.add(websocket)
    print(f"[WS] Клиент подключился. Всего активных: {len(connected_clients)}")
    
    if last_val is not None:
        await websocket.send(last_val)
        
    try:
        # Слушаем входящие команды от веб-страницы
        async for message in websocket:
            if message == "SHUTDOWN":
                print("[SERVER] Получена команда на завершение работы...")
                global ser
                if ser and ser.is_open:
                    ser.close()
                    print("[UART] COM-порт успешно закрыт.")
                
                # Принудительное завершение процесса Python через 0.3 сек
                loop = asyncio.get_running_loop()
                loop.call_later(0.3, lambda: os._exit(0))
                
    finally:
        connected_clients.remove(websocket)

async def main():
    loop = asyncio.get_running_loop()
    loop.run_in_executor(None, uart_reader_thread, loop)
    
    print(f"[SERVER] WebSocket сервер запущен на ws://{WS_HOST}:{WS_PORT}")
    async with websockets.serve(ws_handler, WS_HOST, WS_PORT):
        await asyncio.Future()

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[SERVER] Сервер остановлен.")
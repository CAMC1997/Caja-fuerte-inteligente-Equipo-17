import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

  class BluetoothService {
    BluetoothConnection? _connection;
    final String deviceAddress = '00:22:12:01:CE:B7'; // Dirección del dispositivo Bluetooth

    Future<void> connect() async {
      if (_connection != null && _connection!.isConnected) {
        return; // Si ya estamos conectados, no hacemos nada
      }

      try {
        _connection = await BluetoothConnection.toAddress(deviceAddress);
        print("Dispositivo conectado: $deviceAddress");
        /*
        _connection?.input?.listen((data) {
          print('Datos recibidos: ${ascii.decode(data)}');
        }).onDone(() {
          print('Desconectado');
        });*/
      } catch (e) {
        print("Error al conectar: $e");
        // Manejar el error de conexión aquí
      }
    }

    BluetoothConnection? get connection => _connection; // Getter para la conexión Bluetooth

    void dispose() {
      _connection?.dispose(); // Liberar recursos de la conexión al cerrar
    }
  }

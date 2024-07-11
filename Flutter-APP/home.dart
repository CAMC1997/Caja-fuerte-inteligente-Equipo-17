import 'dart:convert';
import 'package:app_security/exit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_security/provider/bt_services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _password = '';
  bool _bluetoothState = false;
  final _bluetooth = FlutterBluetoothSerial.instance;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initializeBluetooth();
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  void _initializeBluetooth() {
    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
    });

    _bluetooth.onStateChanged().listen((state) {
      print("Bluetooth state changed: $state");
      if (state == BluetoothState.STATE_OFF) {
        setState(() => _bluetoothState = false);
      } else if (state == BluetoothState.STATE_ON) {
        setState(() => _bluetoothState = true);
        Future.delayed(const Duration(seconds: 5), () {
          _receiveData();
        });
      }
    });
  }

  void _receiveData() {
    final bluetoothService = context.read<BluetoothService>();
    bluetoothService.connection?.input?.listen((event) {
      String receivedData = String.fromCharCodes(event);
      print("Recibido: $receivedData");
      if (receivedData.contains("a")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExitScreen()),
        );
      } else if (receivedData.contains("d")) {
        _showAlertDialog(
            context, "Acceso denegado", "La contraseña es incorrecta");
      } else if (receivedData.contains("w")) {
        _showAlertDialog(context, "Advertencia",
            "Alguien está intentando acceder a la caja fuerte");
      }
    });
  }

  void _sendData(String data) {
    final bluetoothService = context.read<BluetoothService>();
    if (bluetoothService.connection?.isConnected ?? false) {
      bluetoothService.connection?.output.add(ascii.encode(data));
    }
  }

  @override
  void dispose() {
    context.read<BluetoothService>().dispose();
    super.dispose();
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_password.length == 6) {
      print("Sending data");
      _sendData(_password);
      setState(() {
        _password = '';
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5E5F62),
        onPressed: () {
          if (_bluetoothState) {
            context.read<BluetoothService>().connect();
          }
        },
        label: const Text('Bluetooth', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.bluetooth, color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
          alignment: Alignment.center,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 80),
                child: SvgPicture.asset(
                  'assets/key.svg',
                  height: 150,
                ),
              ),
              const SizedBox(height: 100),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 64,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E5F62),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _password,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Color(0xFFE0E0E0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 15.0,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // keyboard
                    SizedBox(
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              KeyboardButton(
                                text: '1',
                                onPressed: () {
                                  setState(() {
                                    _password += '1';
                                  });
                                },
                              ),
                              KeyboardButton(
                                text: '2',
                                onPressed: () {
                                  setState(() {
                                    _password += '2';
                                  });
                                },
                              ),
                              KeyboardButton(
                                text: '3',
                                onPressed: () {
                                  setState(() {
                                    _password += '3';
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              KeyboardButton(
                                text: '4',
                                onPressed: () {
                                  setState(() {
                                    _password += '4';
                                  });
                                },
                              ),
                              KeyboardButton(
                                text: '5',
                                onPressed: () {
                                  setState(() {
                                    _password += '5';
                                  });
                                },
                              ),
                              KeyboardButton(
                                text: '6',
                                onPressed: () {
                                  setState(() {
                                    _password += '6';
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              KeyboardButton(
                                text: '7',
                                onPressed: () {
                                  setState(() {
                                    _password += '7';
                                  });
                                },
                              ),
                              KeyboardButton(
                                text: '8',
                                onPressed: () {
                                  setState(() {
                                    _password += '8';
                                  });
                                },
                              ),
                              KeyboardButton(
                                text: '9',
                                onPressed: () {
                                  setState(() {
                                    _password += '9';
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class KeyboardButton extends StatelessWidget {
  const KeyboardButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(76, 76),
        maximumSize: const Size(90, 90),
        backgroundColor: const Color(0xFF5E5F62),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFFE0E0E0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

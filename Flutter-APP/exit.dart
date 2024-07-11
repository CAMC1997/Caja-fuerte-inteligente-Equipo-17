import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:app_security/provider/bt_services.dart';

class ExitScreen extends StatefulWidget {
  const ExitScreen({super.key});

  @override
  State<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  double porcentaje = 0.0;
  Timer? _timer;

  void startCountdown() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (mounted) {
        setState(() {
          porcentaje += 1 / 60;
          if (porcentaje > 1.0) {
            porcentaje = 1.0;
          }
        });
      }

      if (porcentaje == 1.0) {
        timer.cancel();
        _sendData("C");
        Navigator.pop(context);
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
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Center(
        child: CircularPercentIndicator(
          radius: 160.0,
          lineWidth: 40.0,
          percent: porcentaje,
          center: FilledButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFFE66D57)),
            ),
            onPressed: () {
              _sendData("C");
              Navigator.pop(context);
            },
            child: const Text(
              'CERRAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          progressColor: const Color(0xFFE66D57),
          backgroundColor: const Color(0xFFf2b5aa),
        ),
      ),
    );
  }
}

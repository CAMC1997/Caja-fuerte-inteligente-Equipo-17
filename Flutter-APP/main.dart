import 'package:app_security/home.dart';
import 'package:app_security/provider/bt_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => BluetoothService()),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: 'OpenSans'),
        debugShowCheckedModeBanner: false,
        home: const HomePage());
  }
}

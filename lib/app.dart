import 'package:flutter/material.dart';
import 'features/home/home_page.dart';
import 'features/send_data/send_data_page.dart';
import 'features/send_text/send_text_page.dart';
import 'features/send_image/send_image_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT App',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/send-data': (context) => const SendDataPage(),
        '/send-text': (context) => const SendTextPage(),
        '/send-image': (context) => const SendImagePage(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mqtt_test/features/send_image/built_in_images_page.dart';
import 'package:mqtt_test/features/send_image/choose_image_page.dart';
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
      theme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/send-data': (context) => const SendDataPage(),
        '/send-text': (context) => const SendTextPage(),
        '/send-image': (context) => const SendImagePage(),
        '/send_image/built_in': (context) => const SendBuiltInImagePage(),
        '/send_image/choose': (context) => const SendChoosenImagePage(),
      },
    );
  }
}

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF00B4D8),
    onPrimary: Colors.black,
    secondary: Color(0xFF48CAE4),
    onSecondary: Colors.black,
    error: Color(0xFFFF4D6D),
    onError: Colors.white,
    surface: Color(0xFF1B263B),
    onSurface: Color(0xFFE0E1DD),
  ),
  scaffoldBackgroundColor: Color(0xFF0D1B2A),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1B263B),
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF00B4D8),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

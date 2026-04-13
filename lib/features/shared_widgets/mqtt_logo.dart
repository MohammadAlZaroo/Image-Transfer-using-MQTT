import 'package:flutter/material.dart';

class MqttLogo extends StatelessWidget {
  final double size;

  const MqttLogo({super.key, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/mqtt_logo.png',
          width: size,
        ),
      ),
    );
  }
}
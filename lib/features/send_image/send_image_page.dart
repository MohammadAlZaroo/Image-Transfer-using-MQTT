import 'package:flutter/material.dart';
import 'package:mqtt_test/features/shared_widgets/mqtt_logo.dart';

class SendImagePage extends StatelessWidget {
  const SendImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Send Image")),
        body: Stack(
          children: [
            MqttLogo(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/send_image/built_in'),
                  child: const Text("choose from built-in images"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/send_image/choose'),
                  child: const Text("choose from gallery"),
                ),
              ],
            ),
          ],
        ));
  }
}

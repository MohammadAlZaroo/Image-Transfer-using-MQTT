import 'package:flutter/material.dart';
import '../../core/image_processing/image_converter.dart';
import '../../core/mqtt/mqtt_service.dart';

class SendImagePage extends StatelessWidget {
  const SendImagePage({super.key});

  void sendImage(String name) async {
    final bytes = await ImageConverter.convertAssetToMono(name);
    MqttService().publishImage(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Image")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Send clown"),
            onTap: () => sendImage("clown.png"),
          ),
          ListTile(
            title: const Text("Send fire"),
            onTap: () => sendImage("fire.png"),
          ),
          ListTile(
            title: const Text("Send joy"),
            onTap: () => sendImage("joy.png"),
          ),
        ],
      ),
    );
  }
}
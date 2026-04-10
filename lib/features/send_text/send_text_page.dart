import 'package:flutter/material.dart';
import '../../core/mqtt/mqtt_service.dart';

class SendTextPage extends StatefulWidget {
  const SendTextPage({super.key});

  @override
  State<SendTextPage> createState() => _SendTextPageState();
}

class _SendTextPageState extends State<SendTextPage> {
  final controller = TextEditingController();

  void send() {
    MqttService().publishText(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Text")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: controller),
            ElevatedButton(onPressed: send, child: const Text("Send")),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mqtt_test/features/shared_widgets/mqtt_logo.dart';
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
      body: Stack(
        children: [
          MqttLogo(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(labelText: "Enter text to send")),
                ElevatedButton(onPressed: send, child: const Text("Send")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

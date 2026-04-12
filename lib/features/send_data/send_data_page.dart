import 'package:flutter/material.dart';

class SendDataPage extends StatelessWidget {
  const SendDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Data")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/send-text'),
            child: const Text("Send Text"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/send-image'),
            child: const Text("Send Image"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SendBuiltInImagePage extends StatelessWidget {
  const SendBuiltInImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Built-in Image")),
      body: Center(child: Text("This page will show built-in images to send")),
    );
  }
}

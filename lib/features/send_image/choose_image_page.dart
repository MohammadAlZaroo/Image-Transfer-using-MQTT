import 'package:flutter/material.dart';

class SendChoosenImagePage extends StatelessWidget {
  const SendChoosenImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Choosen Image")),
      body: Center(
          child: Text("This page will show images from gallery to send")),
    );
  }
}

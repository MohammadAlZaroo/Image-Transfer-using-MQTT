import 'package:flutter/material.dart';
import '../../core/mqtt/mqtt_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;

  void connect() async {
    setState(() => loading = true);

    bool success = await MqttService().connect();

    if (!mounted) return;

    setState(() => loading = false);

    if (success) {
      Navigator.pushNamed(context, '/send-data');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MQTT Client"),),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: connect,
                child: const Text("Connect to Broker"),
              ),
      ),
    );
  }
}

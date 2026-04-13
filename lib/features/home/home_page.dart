import 'package:flutter/material.dart';
import 'package:mqtt_test/features/shared_widgets/mqtt_logo.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connected successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MQTT Client"),
      ),
      body: Stack(
        children: [
          MqttLogo(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  SizedBox(height: 40), // Logo height + top padding
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Welcome to the MQTT Client App! Press the button below to connect to the broker.",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Center(
                child: loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: connect,
                        child: const Text("Connect to Broker"),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

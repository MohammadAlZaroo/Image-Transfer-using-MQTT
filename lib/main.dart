import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() async {
  final client = MqttServerClient.withPort(
      '5a7e228c56c94e90bf6e3c78066153ee.s1.eu.hivemq.cloud', 'client1', 8883);
  // client.secure = true;
  await client.connect('first', '123456789');

  print('Connected to the broker');

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final MqttServerClient client;
  const MyApp({super.key, required this.client});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'MQTT Publish', client: client),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final MqttServerClient client;
  final String title;
  const MyHomePage({super.key, required this.title, required this.client});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController();
  void _sendMessage() {
    final builder = MqttClientPayloadBuilder();
    builder.addString(textController.text);
    widget.client
        .publishMessage('flutter/test', MqttQos.atLeastOnce, builder.payload!);
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Enter your message',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
              onPressed: _sendMessage,
              child: Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

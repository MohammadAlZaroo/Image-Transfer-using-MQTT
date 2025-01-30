import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'MQTT Publish'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({
    super.key,
    required this.title,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isConnected = false;
  bool isLoading = true;
  final client = MqttServerClient.withPort('192.168.1.5', 'client1', 1883);
  Future<bool> _connectToBroker() async {
    // client.secure = true;
    try {
      await client.connect('narada', 'narada505308');
      return true;
    } catch (e) {
      return false;
    }
  }

  final textController = TextEditingController();
  void _sendMessage() {
    final builder = MqttClientPayloadBuilder();
    builder.addString(textController.text);
    client.publishMessage(
        'flutter/test', MqttQos.atLeastOnce, builder.payload!);
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
        child: isConnected
            ? Column(
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
              )
            : ElevatedButton(
                onPressed: () {
                  isLoading = true;
                  if (isLoading) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Connecting to broker'),
                          content: CircularProgressIndicator(),
                        );
                      },
                    );
                  }

                  _connectToBroker().then(
                    (value) {
                      setState(() {
                        isConnected = value;
                        isLoading = false;
                        Navigator.pop(context);
                      });
                    },
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                )),
      ),
    );
  }
}

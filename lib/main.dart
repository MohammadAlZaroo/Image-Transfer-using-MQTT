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
  final client = MqttServerClient.withPort(
      '5a7e228c56c94e90bf6e3c78066153ee.s1.eu.hivemq.cloud', 'client1', 8883);
  Future<bool> _connectToBroker() async {
    client.secure = true;
    try {
      await client.connect('first', '123456789');
      client.subscribe('flutter/test', MqttQos.atLeastOnce);
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
            ? StreamBuilder<List<MqttReceivedMessage<MqttMessage>>>(
                stream: client.updates, // Receive MQTT updates
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final updates = snapshot.data!;
                  final MqttPublishMessage recMess =
                      updates.last.payload as MqttPublishMessage;
                  final String latestUpdate =
                      MqttPublishPayload.bytesToStringAsString(
                          recMess.payload.message);
                  return Center(child: Text('Latest msg: $latestUpdate'));
                },
              )

            //  Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[

            //       SizedBox(
            //         width: 200,
            //         child: TextField(
            //           controller: textController,
            //           decoration: InputDecoration(
            //             hintText: 'Enter your message',
            //             border: OutlineInputBorder(),
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 20),
            //       ElevatedButton(
            //         style: ButtonStyle(
            //           backgroundColor: WidgetStateProperty.all<Color>(
            //               Theme.of(context).colorScheme.primary),
            //         ),
            //         onPressed: _sendMessage,
            //         child: Text('Send', style: TextStyle(color: Colors.white)),
            //       ),
            //     ],
            //   )
            : ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Connecting to broker'),
                        content: CircularProgressIndicator(),
                      );
                    },
                  );

                  final status = await _connectToBroker();
                  Navigator.pop(context);
                  if (status) {
                    setState(() {
                      isConnected = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connected to broker'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to connect to broker'),
                      ),
                    );
                  }
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

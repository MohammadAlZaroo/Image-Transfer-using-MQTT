import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/bits.dart';

void main() {
  runApp(MyApp());
  // print(exp.length);
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
  final List<String> messages = []; // List to store messages

  Future<bool> _connectToBroker() async {
    client.secure = true;
    try {
      await client.connect('first', '123456789');
      client.subscribe('flutter/test', MqttQos.atLeastOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        setState(() {
          messages.add(message); // Add message to the list
        });
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  final textController = TextEditingController();
  void _sendMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Publish A message'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter your message',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final builder = MqttClientPayloadBuilder();
                builder.addString(textController.text);
                client.publishMessage(
                    'flutter/test', MqttQos.atLeastOnce, builder.payload!);
                textController.clear();
              },
              child: Text('Publish'),
            ),
            ElevatedButton(
                onPressed: () {
                  convertImageToIntArray2().then((value) {
                    sendbitmapArryofInts(imageBytes: value);
                  });
                },
                onLongPress: () {
                  sendbitmapArryofInts(imageBytes: x);
                },
                child: Text('Send Image'))
          ],
        );
      },
    );
  }

  Future<List<int>> convertImageToIntArray() async {
    final ByteData imageData =
        await rootBundle.load('assets/images/expbit.bmp');

    Uint8List imageBytes = imageData.buffer.asUint8List(0, 1024);

    print(imageBytes.length);
    return imageBytes;
  }

  Future<List<int>> convertImageToIntArray2() async {
    // Load BMP file
    final ByteData imageData =
        await rootBundle.load('assets/images/clownbit.bmp');
    Uint8List imageBytes = imageData.buffer.asUint8List();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }
    // Ensure the image is monochrome (grayscale)
    img.Image monoImage = img.grayscale(image);

    // Get image dimensions
    int width = monoImage.width;
    int height = monoImage.height;

    Uint8List imgBytes = Uint8List((width * height) ~/ 8); // 1024 bytes

    // Convert image pixels to bytes
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width ~/ 8; x++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          int pixel = monoImage.getPixel(x * 8 + bit, y);
          int luminance =
              img.getLuminance(pixel); // Get pixel brightness (0-255)
          int bitValue =
              luminance > 128 ? 1 : 0; // Threshold to determine black/white
          byte |= (bitValue << (7 - bit)); // Store bit in the correct position
        }
        imgBytes[y * (width ~/ 8) + x] = byte;
      }
    }

    return imgBytes;
  }

  sendbitmapArrayOfStrings() {
    convertImageToIntArray().then((value) {
      final jsonObject = {
        'image': value,
      };
      print(value.length);
      final jsonString = jsonEncode(jsonObject);
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonString);
      client.publishMessage(
          'flutter/test', MqttQos.atLeastOnce, builder.payload!);
    });
  }

  sendbitmapArryofInts({required List<int> imageBytes}) {
    List<List<int>> imageLists = [];
    const int subArraySize = 32;
    for (int i = 0; i < imageBytes.length ~/ subArraySize; i++) {
      imageLists
          .add(imageBytes.sublist(i * subArraySize, (i + 1) * subArraySize));
    }
    for (int i = 0; i < imageLists.length; i++) {
      final jsonObject = {
        'imageIndex$i': imageLists[i],
      };

      final jsonString = jsonEncode(jsonObject);
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonString);
      client.publishMessage(
          'flutter/test', MqttQos.atLeastOnce, builder.payload!);
    }
  }

  send1024OfArrayElements() {
    for (int i = 0; i < y.length; i++) {
      final jsonObject = {
        'imageIndex$i': y[i],
      };
      final jsonString = jsonEncode(jsonObject);
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonString);
      client.publishMessage(
          'flutter/test', MqttQos.atLeastOnce, builder.payload!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        child: Icon(Icons.send),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isConnected
            ? messages.isEmpty
                ? Center(
                    child: Text('No Messages'),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          messages[index],
                        ),
                      );
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

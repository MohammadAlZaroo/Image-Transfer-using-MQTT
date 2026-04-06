import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

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
  _reconnect() async {
    while (true) {
      await Future.delayed(Duration(seconds: 4));
      if (client.connectionStatus!.state == MqttConnectionState.disconnected) {
        setState(() {
          isConnected = false;
        });
      }
    }
  }

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
                  convertImageToIntArray('clown.png').then((value) {
                    sendbitmapArryofInts(imageBytes: value);
                  });
                  convertImageToIntArray('exp.png').then((value) {
                    sendbitmapArryofInts(imageBytes: value);
                  });
                  convertImageToIntArray('fire.png').then((value) {
                    sendbitmapArryofInts(imageBytes: value);
                  });
                  convertImageToIntArray('joy.png').then((value) {
                    sendbitmapArryofInts(imageBytes: value);
                  });
                  convertImageToIntArray('like.png').then((value) {
                    sendbitmapArryofInts(imageBytes: value);
                  });
                },
                onLongPress: () {
                  readImage('like.png').then((value) {
                    img.Image image = cannyEdgeDetection(value);
                    sendbitmapArryofInts(
                        imageBytes: convertImageToByteArray(image));
                  });

                  readImage('joy.png').then((value) {
                    img.Image image = cannyEdgeDetection(value);
                    sendbitmapArryofInts(
                        imageBytes: convertImageToByteArray(image));
                  });

                  readImage('fire.png').then((value) {
                    img.Image image = cannyEdgeDetection(value);
                    sendbitmapArryofInts(
                        imageBytes: convertImageToByteArray(image));
                  });

                  readImage('exp.png').then((value) {
                    img.Image image = cannyEdgeDetection(value);
                    sendbitmapArryofInts(
                        imageBytes: convertImageToByteArray(image));
                  });

                  readImage('clown.png').then((value) {
                    img.Image image = cannyEdgeDetection(value);
                    sendbitmapArryofInts(
                        imageBytes: convertImageToByteArray(image));
                  });
                },
                child: Text('Send Image'))
          ],
        );
      },
    );
  }

  Future<List<int>> convertImageToIntArray(String name) async {
    // Load BMP file
    final ByteData imageData = await rootBundle.load('assets/images/$name');
    Uint8List imageBytes = imageData.buffer.asUint8List();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }
    // Ensure the image is monochrome (grayscale)
    img.Image monoImage = img.grayscale(image);
    List<int> histogram = computeHistogram(monoImage);
    int threshold = otsuThreshold(histogram);
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
          int bitValue = luminance > (threshold - 1)
              ? 1
              : 0; // Threshold to determine black/white
          byte |= (bitValue << (7 - bit)); // Store bit in the correct position
        }
        imgBytes[y * (width ~/ 8) + x] = byte;
      }
    }

    return imgBytes;
  }

  Future<img.Image> readImage(String name) async {
    final ByteData imageData = await rootBundle.load('assets/images/$name');
    Uint8List imageBytes = imageData.buffer.asUint8List();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    return image;
  }

  /// Applies Canny edge detection to an image.
  img.Image cannyEdgeDetection(img.Image image,
      {double? lowThreshold, double? highThreshold}) {
    // Convert to grayscale
    img.Image grayImage = img.grayscale(image);

    int width = grayImage.width;
    int height = grayImage.height;

    // Step 1: Apply Gaussian Blur
    List<List<double>> gaussianKernel = [
      [2, 4, 5, 4, 2],
      [4, 9, 12, 9, 4],
      [5, 12, 15, 12, 5],
      [4, 9, 12, 9, 4],
      [2, 4, 5, 4, 2]
    ];
    double kernelSum =
        gaussianKernel.expand((row) => row).reduce((a, b) => a + b);
    grayImage = applyConvolution(grayImage, gaussianKernel, kernelSum);

    // Step 2: Compute Gradients using Sobel Operator
    List<List<int>> sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ];
    List<List<int>> sobelY = [
      [1, 2, 1],
      [0, 0, 0],
      [-1, -2, -1]
    ];

    List<List<double>> gradientMagnitude =
        List.generate(height, (_) => List.filled(width, 0.0));
    List<List<double>> gradientDirection =
        List.generate(height, (_) => List.filled(width, 0.0));

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double gx = 0, gy = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            int pixel = grayImage.getPixel(x + kx, y + ky) & 0xFF;
            gx += pixel * sobelX[ky + 1][kx + 1];
            gy += pixel * sobelY[ky + 1][kx + 1];
          }
        }

        gradientMagnitude[y][x] = sqrt(gx * gx + gy * gy);
        gradientDirection[y][x] = atan2(gy, gx);
      }
    }

    // Step 3: Non-Maximum Suppression
    img.Image suppressedImage = img.Image(width, height);
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double angle = gradientDirection[y][x] * (180.0 / pi);
        angle = (angle < 0) ? angle + 180 : angle;

        double mag = gradientMagnitude[y][x];
        double q = 255, r = 255;

        if ((angle >= 0 && angle < 22.5) || (angle >= 157.5 && angle <= 180)) {
          q = gradientMagnitude[y][x + 1];
          r = gradientMagnitude[y][x - 1];
        } else if (angle >= 22.5 && angle < 67.5) {
          q = gradientMagnitude[y + 1][x - 1];
          r = gradientMagnitude[y - 1][x + 1];
        } else if (angle >= 67.5 && angle < 112.5) {
          q = gradientMagnitude[y + 1][x];
          r = gradientMagnitude[y - 1][x];
        } else if (angle >= 112.5 && angle < 157.5) {
          q = gradientMagnitude[y - 1][x - 1];
          r = gradientMagnitude[y + 1][x + 1];
        }

        if (mag >= q && mag >= r) {
          suppressedImage.setPixel(
              x, y, img.getColor(mag.toInt(), mag.toInt(), mag.toInt()));
        } else {
          suppressedImage.setPixel(x, y, img.getColor(0, 0, 0));
        }
      }
    }
    if (lowThreshold == null || highThreshold == null) {
      final histo = computeHistogram(suppressedImage);
      highThreshold = otsuThreshold(histo).toDouble();
      lowThreshold = highThreshold * 0.5;
    }

    // Step 4: Double Thresholding & Edge Tracking by Hysteresis
    img.Image finalImage = img.Image(width, height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = suppressedImage.getPixel(x, y) & 0xFF;
        if (pixel >= highThreshold) {
          finalImage.setPixel(x, y, img.getColor(255, 255, 255)); // Strong edge
        } else if (pixel >= lowThreshold) {
          bool isEdge = false;
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              if (y + ky >= 0 &&
                  y + ky < height &&
                  x + kx >= 0 &&
                  x + kx < width) {
                int neighborPixel =
                    suppressedImage.getPixel(x + kx, y + ky) & 0xFF;
                if (neighborPixel >= highThreshold) {
                  isEdge = true;
                  break;
                }
              }
            }
            if (isEdge) break;
          }

          if (!isEdge) {
            for (int ky = -2; ky <= 2; ky++) {
              for (int kx = -2; kx <= 2; kx++) {
                if (y + ky >= 0 &&
                    y + ky < height &&
                    x + kx >= 0 &&
                    x + kx < width) {
                  int neighborPixel =
                      suppressedImage.getPixel(x + kx, y + ky) & 0xFF;
                  if (neighborPixel >= highThreshold) {
                    isEdge = true;
                    break;
                  }
                }
              }
              if (isEdge) break;
            }
          }

          if (isEdge) {
            finalImage.setPixel(x, y, img.getColor(255, 255, 255)); // Edge
          } else {
            finalImage.setPixel(x, y, img.getColor(0, 0, 0)); // No edge
          }
        } else {
          finalImage.setPixel(x, y, img.getColor(0, 0, 0)); // No edge
        }
      }
    }

    return finalImage;
  }

  /// Applies a convolution filter to an image.
  img.Image applyConvolution(
      img.Image image, List<List<double>> kernel, double kernelSum) {
    int width = image.width;
    int height = image.height;
    img.Image result = img.Image(width, height);

    int kSize = kernel.length;
    int kOffset = kSize ~/ 2;

    for (int y = kOffset; y < height - kOffset; y++) {
      for (int x = kOffset; x < width - kOffset; x++) {
        double sum = 0;

        for (int ky = 0; ky < kSize; ky++) {
          for (int kx = 0; kx < kSize; kx++) {
            int pixel =
                image.getPixel(x + kx - kOffset, y + ky - kOffset) & 0xFF;
            sum += pixel * kernel[ky][kx];
          }
        }

        sum = sum / kernelSum;
        result.setPixel(
            x, y, img.getColor(sum.toInt(), sum.toInt(), sum.toInt()));
      }
    }
    return result;
  }

  Uint8List convertImageToByteArray(img.Image image) {
    int width = image.width;
    int height = image.height;
    Uint8List imgBytes = Uint8List((width * height) ~/ 8);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width ~/ 8; x++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          int pixel = image.getPixel(x * 8 + bit, y) & 0xFF;
          int bitValue = pixel == 255 ? 1 : 0; // White = 1, Black = 0
          byte |= (bitValue << (7 - bit));
        }
        imgBytes[y * (width ~/ 8) + x] = byte;
      }
    }

    return imgBytes;
  }

  List<int> computeHistogram(img.Image image) {
    List<int> histogram = List.filled(image.height * image.width, 0);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int luminance = img.getLuminance(pixel);
        histogram[luminance]++;
      }
    }
    return histogram;
  }

  int otsuThreshold(List<int> histogramCounts) {
    int total =
        histogramCounts.reduce((a, b) => a + b); // Total number of pixels
    int top = 256;
    int sumB = 0;
    int wB = 0;
    double maximum = 0.0;
    int level = 0;

    // Compute the sum of intensity values times their frequencies
    int sum1 = List.generate(top, (i) => i * histogramCounts[i])
        .reduce((a, b) => a + b);

    for (int i = 0; i < top; i++) {
      int wF = total - wB;
      if (wB > 0 && wF > 0) {
        double mF = (sum1 - sumB) / wF;
        double val = wB * wF * ((sumB / wB) - mF) * ((sumB / wB) - mF);
        if (val >= maximum) {
          level = i;
          maximum = val;
        }
      }
      wB += histogramCounts[i];
      sumB += i * histogramCounts[i];
    }

    return level;
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

  @override
  void initState() {
    super.initState();
    _reconnect();
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

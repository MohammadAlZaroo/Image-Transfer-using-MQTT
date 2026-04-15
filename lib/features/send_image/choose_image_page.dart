import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mqtt_test/core/image_processing/image_converter.dart';

import '../../core/mqtt/mqtt_service.dart';

class SendChoosenImagePage extends StatefulWidget {
  const SendChoosenImagePage({super.key});

  @override
  State<SendChoosenImagePage> createState() => _SendChoosenImagePageState();
}

class _SendChoosenImagePageState extends State<SendChoosenImagePage> {
  File? selectedImage;
  bool isSending = false;

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        print(selectedImage?.path);
        print("hiiiiiiiiiiiiiiiiiiiiiiii");
      });
    }
  }

  Future<void> sendImage() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      /// Read image
      /// 
      // ImageConverter.convertImageToIntArray("/data/user/0/com.example.mqtt_test/cache/b9d228b4-78d2-4fa7-a231-35c7bcaa8e5a/1000043571.jpg").then((value) {
      //     MqttService().publishImage(value);
      // });

      Uint8List bytes = await selectedImage!.readAsBytes();
      img.Image? original = img.decodeImage(bytes);
      ImageConverter.convertImageToIntArray("", original).then((value) {
          MqttService().publishImage(value);
      });
      // if (original == null) throw Exception("Invalid image");

      // img.Image resized = img.copyResize(
      //   original,
      //   width: 128,
      //   height: 64,
      // );

      // img.Image gray = img.grayscale(resized);

      // /// Convert to 1-bit (OLED format)
      // Uint8List output = Uint8List((128 * 64) ~/ 8);

      // for (int y = 0; y < 64; y++) {
      //   for (int x = 0; x < 128 ~/ 8; x++) {
      //     int byte = 0;

      //     for (int bit = 0; bit < 8; bit++) {
      //       int pixel = gray.getPixel(x * 8 + bit, y);
      //       int lum = img.getLuminance(pixel);

      //       int bitValue = lum > 128 ? 1 : 0;
      //       byte |= (bitValue << (7 - bit));
      //     }

      //     output[y * (128 ~/ 8) + x] = byte;
      //   }
      // }

      // MqttService().publishImage(output);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image sent successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing image")),
      );
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Image")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// 🔹 Image Preview
          Expanded(
            child: Center(
              child: selectedImage == null
                  ? const Text("No image selected")
                  : Image.file(selectedImage!),
            ),
          ),

          /// 🔹 Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("Pick Image"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isSending ? null : () => sendImage(),
                  child: isSending
                      ? const CircularProgressIndicator()
                      : const Text("Send Image"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

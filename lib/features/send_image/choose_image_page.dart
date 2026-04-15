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

      Uint8List bytes = await selectedImage!.readAsBytes();
      img.Image? original = img.decodeImage(bytes);
      if (original == null) throw Exception("Invalid image");
      img.Image resized = img.copyResize(
        original,
        width: 128,
        height: 64,
      );
      ImageConverter.convertImageToIntArray("", resized).then((value) {
        MqttService().publishImage(value);
      });

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

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

Uint8List reconstructedImage = Uint8List(0);
Uint8List pickedImage = Uint8List(0);
bool withEdgeMode = false;

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

    selectedImage!.readAsBytes().then((bytes) {
      img.Image? original = img.decodeImage(bytes);

      ImageConverter.convertImageToIntArray("", original).then((value) {
        setState(() {
          reconstructedImage = ImageConverter.imageToDisplay(
              ImageConverter.reconstructImageFromBytes(value));
        });
      });
    });
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

      ImageConverter.convertImageToIntArray("", original).then((value) {
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
          Center(
            child: selectedImage == null
                ? const Text("No image selected")
                : Column(
                    children: [
                      Text("Selected Image:"),
                      const SizedBox(height: 10),
                      Image.file(selectedImage!, width: 128, height: 64),
                      const SizedBox(height: 10),
                      Text("how the image looks like:"),
                      const SizedBox(height: 10),
                      reconstructedImage.isEmpty
                          ? const Text("Processing image...")
                          : Image.memory(
                              reconstructedImage,
                              width: 128,
                              height: 64,
                            ),
                      const SizedBox(height: 10),
                      Text("how the Edge image looks like:"),
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                    ],
                  ),
          ),

          /// 🔹 Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: const Text("Pick Image"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isSending ? null : () => sendImage(),
                  child: isSending
                      ? const CircularProgressIndicator()
                      : const Text("Send Image"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isSending ? null : () => (),
                  child: isSending
                      ? const CircularProgressIndicator()
                      : const Text("Send Image Edges"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

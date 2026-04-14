import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../core/image_processing/image_converter.dart';
import '../../core/mqtt/mqtt_service.dart';

class SendBuiltInImagePage extends StatefulWidget {
  const SendBuiltInImagePage({super.key});

  @override
  State<SendBuiltInImagePage> createState() => _SendBuiltInImagePageState();
}

Uint8List reconstructedImage = Uint8List(0);

class _SendBuiltInImagePageState extends State<SendBuiltInImagePage> {
  /// 🔹 Your built-in images
  final List<String> images = [
    "clown.png",
    "fire.png",
    "joy.png",
    "like.png",
    "exp.png",
  ];

  int? selectedIndex;
  bool isSending = false;

  void sendSelectedImage() async {
    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    setState(() => isSending = true);

    final selectedImage = images[selectedIndex!];

    try {
      // the following two lines needs change.
      ImageConverter.convertImageToIntArray(selectedImage).then((value) {
        MqttService().publishImage(value);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image sent successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending image")),
      );
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Built-in Images")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 images per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2, // important for 128x64 ratio
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      ImageConverter.convertImageToIntArray(images[index])
                          .then((value) {
                        ImageConverter.reconstructImageFromBytes(value);
                        reconstructedImage = ImageConverter.imageToDisplay();
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          /// Image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/${images[index]}',
                              fit: BoxFit.cover,
                            ),
                          ),

                          if (isSelected)
                            const Positioned(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white70,
                                size: 25,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (reconstructedImage.isNotEmpty)
            Column(
              children: [
                Text("The Image will look like this on the OLED screen"),
                Image.memory(reconstructedImage, width: 128, height: 64),
              ],
            ),

          /// 🔹 Send Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSending ? null : sendSelectedImage,
                child: isSending
                    ? const CircularProgressIndicator()
                    : const Text("Send Image"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

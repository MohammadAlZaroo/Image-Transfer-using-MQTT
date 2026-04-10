import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageConverter {
  static Future<List<int>> convertAssetToMono(String name) async {
    final data = await rootBundle.load('assets/images/$name');
    Uint8List bytes = data.buffer.asUint8List();

    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Invalid image");

    img.Image gray = img.grayscale(image);

    int width = gray.width;
    int height = gray.height;

    Uint8List output = Uint8List((width * height) ~/ 8);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width ~/ 8; x++) {
        int byte = 0;

        for (int bit = 0; bit < 8; bit++) {
          int pixel = gray.getPixel(x * 8 + bit, y);
          int lum = img.getLuminance(pixel);

          int bitValue = lum > 128 ? 1 : 0;
          byte |= (bitValue << (7 - bit));
        }

        output[y * (width ~/ 8) + x] = byte;
      }
    }

    return output;
  }
}
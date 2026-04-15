import 'dart:async';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

img.Image reconstructed = img.Image(128, 64);
img.Image reconstructedEdge = img.Image(128, 64);

class ImageConverter {
// test function to read image and return it as img.Image
  static Future<img.Image> readImage(String name) async {
    final ByteData imageData = await rootBundle.load('assets/images/$name');
    Uint8List imageBytes = imageData.buffer.asUint8List();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    return image;
  }

  static Future<List<int>> convertImageToIntArray(String name,
      [img.Image? image]) async {
    // Load BMP file
    if (image == null) {final ByteData imageData = await rootBundle.load('assets/images/$name');
    Uint8List imageBytes = imageData.buffer.asUint8List();
     image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }}
    
          img.Image resized = img.copyResize(
        image,
        width: 128,
        height: 64,
      );
    // Ensure the image is monochrome (grayscale)
    img.Image monoImage = img.grayscale(resized);
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

// Reconstruct monochrome image from byte array
  static img.Image reconstructImageFromBytes(
    List<int> bytes, {
    int width = 128,
    int height = 64,
  }) {
    img.Image image = img.Image(width, height);

    int bytesPerRow = width ~/ 8;

    for (int y = 0; y < height; y++) {
      for (int xByte = 0; xByte < bytesPerRow; xByte++) {
        int byte = bytes[y * bytesPerRow + xByte];

        for (int bit = 0; bit < 8; bit++) {
          int x = xByte * 8 + bit;

          /// Extract bit (same order as encoding)
          int bitValue = (byte >> (7 - bit)) & 1;

          int color = bitValue == 1 ? 255 : 0;

          image.setPixel(
            x,
            y,
            img.getColor(color, color, color),
          );
        }
      }
    }
    return image;
  }

  void selectImage(int index) {
    if (index == 0) {}
  }

  static Uint8List imageToDisplay(img.Image image) {
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Applies Canny edge detection to an image.
  static img.Image cannyEdgeDetection(img.Image image,
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
  static img.Image applyConvolution(
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

  static Uint8List convertImageToByteArray(img.Image image) {
        image = img.copyResize(
        image,
        width: 128,
        height: 64,
      );
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

  static List<int> computeHistogram(img.Image image) {
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

  static int otsuThreshold(List<int> histogramCounts) {
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
}
//-----------------------------------------------

import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;

  MqttService._internal();

  final client = MqttServerClient.withPort(
      '5a7e228c56c94e90bf6e3c78066153ee.s1.eu.hivemq.cloud',
      'client1',
      8883);

  bool isConnected = false;

  Future<bool> connect() async {
    client.secure = true;

    try {
      await client.connect('first', '123456789');
      isConnected = true;
      return true;
    } catch (e) {
      isConnected = false;
      return false;
    }
  }

  void publishText(String text) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(text);
    client.publishMessage('flutter/test', MqttQos.atLeastOnce, builder.payload!);
  }

  void publishImage(List<int> imageBytes) {
    const int chunkSize = 32;

    for (int i = 0; i < imageBytes.length ~/ chunkSize; i++) {
      final chunk = imageBytes.sublist(i * chunkSize, (i + 1) * chunkSize);

      final json = jsonEncode({
        "type": "image",
        "index": i,
        "data": chunk,
      });

      final builder = MqttClientPayloadBuilder();
      builder.addString(json);

      client.publishMessage(
          'flutter/test', MqttQos.atLeastOnce, builder.payload!);
    }
  }
}
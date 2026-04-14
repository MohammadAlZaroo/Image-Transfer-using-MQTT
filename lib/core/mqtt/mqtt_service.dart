import 'dart:convert';
import 'dart:async';
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
  }

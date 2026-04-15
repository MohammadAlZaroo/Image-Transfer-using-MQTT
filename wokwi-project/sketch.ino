
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ArduinoJson.h>


#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels
#define OLED_RESET    -1 // Reset pin # (or -1 if sharing Arduino reset pin)

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET); 
#define EMOJI_HEIGHT   64
#define EMOJI_WIDTH    128


// Wi-Fi credentials
const char* ssid = "Wokwi-GUEST";
const char* password = "";

// MQTT broker details private
const char* mqtt_broker = "5a7e228c56c94e90bf6e3c78066153ee.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;

const char* mqtt_username = "first";
const char* mqtt_password = "123456789";

// MQTT topics
const char* topic_publish = "TempHumdata";
const char* topic_subscribe = "flutter/test"; // Topic to receive messages


// Create instances
WiFiClientSecure wifiClient;
PubSubClient mqttClient(wifiClient);


void setupMQTT() {
  mqttClient.setServer(mqtt_broker, mqtt_port);
  mqttClient.setCallback(mqttCallback);
}

void reconnect() {
  Serial.println("Connecting to MQTT Broker...");
  while (!mqttClient.connected()) {
    Serial.println("Reconnecting to MQTT Broker...");
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);
    
    if (mqttClient.connect(clientId.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("Connected to MQTT Broker.");

      // Subscribe to the control topic
      mqttClient.subscribe(topic_subscribe);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(mqttClient.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}


const int numSubarrays = 32;
const int subarraySize = 32;
uint8_t imageData[numSubarrays * subarraySize] = {0};
bool receivedParts[numSubarrays] = {false};

// Callback function to handle incoming messages
void mqttCallback(char* topic, byte* payload, unsigned int length) { // 239 is the maximum String length the CallBack Can Recive
  Serial.print("Message arrived on topic: [");
  Serial.print(topic);
  Serial.print("]: \t");
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);

    if((String)topic == "flutter/test"){
      DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, message);
    if (error) {
      displayText(message);
      Serial.print("Failed to parse JSON: ");
      Serial.println(error.f_str());
      return;
    }

    for (int i = 0; i < numSubarrays; i++) {
    String key = "imageIndex" + String(i);
    if (doc.containsKey(key)) {
      JsonArray arr = doc[key];
      for (int j = 0; j < subarraySize; j++) {
        imageData[i * subarraySize + j] = arr[j];
      }
      receivedParts[i] = true;
    }
  }

  if (allPartsReceived()) {
    displayImage();
  }
    }
}

bool allPartsReceived() {
  for (int i = 0; i < numSubarrays; i++) {
    if (!receivedParts[i]){
      Serial.print("part number ");
      Serial.print(i);
      Serial.println(" is missing ");

      return false;
    }
  }
  return true;
}

void displayImage() {
  display.clearDisplay();
  display.drawBitmap(0, 0, imageData, SCREEN_WIDTH, SCREEN_HEIGHT, WHITE);
  display.display();
  for(int i=0;i<numSubarrays*subarraySize;i++){
    imageData[i] = 0;
  }
  for(int i=0;i<numSubarrays;i++){
    receivedParts[i] = 0;
  }
}

void displayText(String text){
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0, 0);
  display.println(text);
  display.display();

}

void wifiSetup(){
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connencting to the network.");
  }
  Serial.println("");
  Serial.println("Connected to Wi-Fi");
  }


void setup() {
  
  Serial.begin(115200);
  
  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;); // Don't proceed, loop forever
  }
  
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(WHITE);
  display.setCursor(20, 20);
  display.println("Welcome!");
  display.display(); 

  wifiSetup();

  // Initialize secure WiFiClient
  wifiClient.setInsecure(); // Use this only for testing, it allows connecting without a root certificate
  
  setupMQTT();
  
}

void loop() {
  
  if (!mqttClient.connected()) {
    reconnect();
  }
  mqttClient.loop();
  

   // mqttClient.publish(topic_publish, "gdgs"); // it tackes a refrence of String
    delay(50);
   
  
}

# Image Transfer using MQTT in Flutter

This Flutter application demonstrates how to transfer images using MQTT protocol to an ESP32 and display them on a OLED screen. Although the MQTT is not the best option for image transfer (because of the overhead and complexity), this project serves as a proof of concept to show how MQTT can be used for this purpose. In fact the buffer size of the MQTT message is limited, so the image is split into smaller chunks and sent as multiple messages. The ESP32 then reassembles the chunks to display the image on the OLED screen.

I also implemented the famous Canny edge detection algorithm to process the image before sending it to the ESP32. This allows us to see the edges of the image clearly on the OLED screen, which is especially useful for low-resolution displays. Note that there is no library available for Canny edge detection in Flutter, so I had to implement it from scratch. The implementation is not optimized for performance, but it works well for small images.

This project combines Mobile application development, IoT, and Image Processing.

**the project is under development, and i will provide screenshots and more details soon.**

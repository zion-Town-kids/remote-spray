# Remote Spray

[Add description of the project]

## Material / Shopping list
### Electronics
#### Microcontroller (aka Arduino): ESP32
* [Shopping link](https://aliexpress.com/item/32916569687.html): 4.21 $ (2020-04-19)
* Any Arduino like board that has builtin Bluetooth should do the job

#### Servo motor
* [Shopping link](https://aliexpress.com/item/32977139335.html) 3.94 $ (2020-04-19)
* Any servo motor with at least X torque should do the job

#### Battery
* Any smartphone power bank

## Set up and testing components
Follow this steps to configure and test your device, specially the Bluetooth. You may have to change some code to make it workable with your device.

#### Arduino
1. Install arduino
2. Install device on Arduino IDE: File / Preferences / Enter `https://dl.espressif.com/dl/package_esp32_index.json` into the Additional Board Manager URLs field. Then go to Tools / board mannager / look for ESP32 and install.
3. Select the board: Tools / Board / ESP32 Dev Module, and select the upload speed to 115200
3. You may have to give permission to the usb device, example `sudo chmod 666 /dev/ttyUSB0`
4. Paste this code into the editor: 
```c++ 
void setup() {
    Serial.begin(9600); //Start Serial monitor in 9600
    Serial.println("Hello World");
}

void loop(){
    
}
```

5. Upload the code using the => button
6. Open the Serial Montior (and make sure it's set to 9600 baud)
7. Reset the device (in the case of our device by pressing the button in the board)
8. You should see the message `Hello World` each time you reset the device

#### Bluetooth
1. Now let's try test the bluetooth. Upload this code:
```c++
#include "BluetoothSerial.h"

BluetoothSerial BtDev;
int incoming;
int LED_BUILTIN = 2;

void setup() {
  Serial.begin(9600); //Start Serial monitor in 9600
  BtDev.begin("Remote Spry"); //Name of your Bluetooth Signal
  Serial.println("Bluetooth Device is Ready to Pair");

  pinMode (LED_BUILTIN, OUTPUT);//Specify that LED pin is output

}

void loop() {
  if (BtDev.available()) { // Is there a new message?
    incoming = BtDev.read(); //Read what we recevive 
    Serial.print("Received:"); Serial.println(incoming);
    
    if (incoming == 48) { // 48: ASCI code for "0"
        Serial.println("Received message: 10");
        digitalWrite(LED_BUILTIN, LOW); // Turn off led
        BtDev.println("LED turned OFF"); // Sende bluetooth message
    }

    if (incoming == 49){ // 49: ASCI code for "1"
        Serial.println("Received message: 1");
        digitalWrite(LED_BUILTIN, HIGH); // Turn on led
        BtDev.println("LED turned ON"); // Sende bluetooth message
    }
        
    else {
      Serial.println("Unknown message received");
    }
  }
  else {
    Serial.println("There are no new messages");
  }
  delay(1000); // Sleep 1s (1000ms)

}
```

2. Pair the device in your smartphone (as you would with any BT device, you should find it under the name `Remote Spry`)
3. Download a Bluetooth Terminal in your smartphone, such as [this one](https://f-droid.org/packages/ru.sash0k.bluetooth_terminal/)
4. Connect to "Remote Spry" using the Bluetooth terminal, and send `0` and `1`. You should get the messages `LED turned OFF` and `LED turned ON` right after sending the messages.

#### Servo motor
1. Attach one of the pieces that come with the servo
2. Wire the servo to the microcontroller:
	* red => 5v
    * brown => ground
    * orange => PWM (we bill be using the pin #13. Make sure that you use a pin that can be used for PWM on your board.
3. We'll need to install specific version of Servo library for our device. Go to Tools / Manage Libraries ..., inside Arduino IDE, search and install `ServoESP32`. If you use another device, maybe it's compatible with the default servo library (so you don't have to do this step, or maybe it requires another equivalent). 
3. Upload this code:
```c++
#include <Servo.h> 

int servoPin = 13;   // PWM PIN where the servo control signal is connected (change it according to your device and schematic)
Servo motor; 

void setup() { 
   // We need to attach the servo to the used pin number 
   motor.attach(servoPin);
   // Make servo go to 0 degrees 
   motor.write(0); 
   delay(1000); 
   // Make servo go to 90 degrees 
   motor.write(90); 
   delay(1000); 
   // Make servo go to 180 degrees 
   motor.write(180); 
   delay(1000); 
}
void loop(){ 

}
```

4. The motor should rotate 90º wait one second, rotate another 90º, wait one second, and then back to the initial position.

## Mobile app
At the moment there is only application for Android. But since it's coded using Flutter, it should be really easy to make it work for iOS. The proble is that I don't have a mac. If you have one please try to make it work for iOS :)

As of now the app is not releases in any way and if you want to try you must instal flutter and compile it yourself. This should change soon.

## Credits and refs
### For set up and testing components:
* [Arduino servo motors](https://www.instructables.com/id/Arduino-Servo-Motors)
* [ESP32 Servo motors](https://microcontrollerslab.com/esp32-servo-motor-web-server-arduino/)
* [ESP32 Bluetooth](https://circuitdigest.com/microcontroller-projects/using-classic-bluetooth-in-esp32-and-toogle-an-led)
### For mobile app
* [Bluetooth for flutter](https://github.com/edufolly/flutter_bluetooth_serial)
#### Assets:
* [Radar GIF](https://media.giphy.com/media/TKijmiXU6z700j6Gkp/giphy.gif)
* [Paint effect GIF](https://giphy.com/gifs/90s-80s-glitch-xUA7aM80YLoJEj5yxO)

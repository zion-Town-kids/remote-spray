#include "BluetoothSerial.h"
#include <Servo.h> 

Servo motor; 
BluetoothSerial BtDev;

const bool debug = true;
const int servoPin = 13;   // PWM PIN where the servo control signal is connected (change it according to your device and schematic)
const int idleAngle = 0; //Angle in which the servo will be rotated when not painting
const int paintAngle = 90; //Angle in which the servo will be rotated when painting
const int refreshPeriod = 20; //Sleep time beetween reads for new bluetooth messages in ms

void setup() { 
   // We need to attach the servo to the used pin number 
    motor.attach(servoPin);
    // Start the serial port if debug is enabled
    if(debug){
      Serial.begin(9600); //Serial monitor in 9600 (to log messages in the computer)  
    }
    
    BtDev.begin("Remote Spry"); //Name of your Bluetooth Signal
    log("\nSetup done.");
}

void loop(){ 
  if (BtDev.available()) { // Is there a new message?
    int incoming = BtDev.read(); //Read what we recevive 
    if (incoming == 48) { // 48: ASCI code for "0"
      // Stop painting
      log("Stop painting");
      BtDev.println("Stop painting");
      motor.write(idleAngle); 
    }
    else if (incoming == 49) { // 49: ASCI code for "1"
      // Start painting
      log("Start painting");
      BtDev.println("Start painting");
      motor.write(paintAngle); 
    }
    // else {
    //   // Unknown message
    //   log("Unknown message received: " + String(incoming));
    //   BtDev.println("Unknown message received: " + String(incoming));
    // }
  }
  delay(refreshPeriod);
}

// Log message to serial port if debug is enabled
void log(String msg) {
  if(debug) {
    Serial.println(msg);
  }
}
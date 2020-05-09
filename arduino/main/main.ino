#include "BluetoothSerial.h"
#include <Servo.h> 

Servo motor; 
BluetoothSerial BtDev;

const bool debug = true;
const int servoPin = 13;   // PWM PIN where the servo control signal is connected (change it according to your device and schematic)
const int idleAngle = 100; //Angle in which the servo will be rotated when not painting
const int paintAngle = 50; //Angle in which the servo will be rotated when painting
const int refreshPeriod = 30; //Sleep time beetween reads for new bluetooth messages in ms

void setup() { 
   // We need to attach the servo to the used pin number 
    motor.attach(servoPin);
    // Start the serial port if debug is enabled
    if(debug){
      Serial.begin(9600); //Serial monitor in 9600 (to log messages in the computer)  
    }
    
    BtDev.begin("Remote Spry"); //Name of your Bluetooth Signal
    Serial.println("\nSetup done.");
}

void loop(){
  int goTo = getNextAngle();
  Serial.println("going to: ");
  Serial.println(goTo);
  if (goTo != 666) {
    motor.write(goTo);
    delay(refreshPeriod);
  }
}

int getNextAngle(void){
  const int buffLen = 5;
  int buff[buffLen];
  int i = 0;
  bool found = false;
  while(i < buffLen && !found) {
    if (BtDev.available()) { // Is there a new message?
      int incoming = BtDev.read(); // Read it
      buff[i] = incoming; // Put it in the buffer
      if(i > 0 && buff[i-1] == 13 && buff[i] == 10) { // Done?
        found = true;
      }
      i++;
    }
  }
  if (!found) {
    return 666;
  }
  int res = 0;
  int pos = 1;
  for (int j = i - 3; j >= 0; j--) {
    res += (buff[j] - 48) * pos;
    pos *= 10;
  }
  if(res < 0 || res > 360) {
    return 666;
  }
  return res;
}

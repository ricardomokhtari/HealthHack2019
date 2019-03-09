// Accelerometer Setup
#include <Wire.h>
#include <Adafruit_MMA8451.h>
#include <Adafruit_Sensor.h>

Adafruit_MMA8451 mma = Adafruit_MMA8451();

// Flexometer Setup
const int FLEX_PIN = A0; // Pin connected to voltage divider output

// Measure the voltage at 5V and the actual resistance of your
// 47k resistor, and enter them below:
const float VCC = 4.98; // Measured voltage of Ardunio 5V line
const float R_DIV = 47500.0; // Measured resistance of 3.3k resistor

// Upload the code, then try to adjust these values to more
// accurately calculate bend degree.
const float STRAIGHT_RESISTANCE = 40054.0; // resistance when straight
const float BEND_RESISTANCE =  52000.00; // resistance at 90 deg

// Bluetooth Setup
#include <SoftwareSerial.h>
SoftwareSerial mySerial(8,9);


void setup() {
  // Initialising serial
  Serial.begin(9600);

  // Checking Accelerometer is working
  if (! mma.begin()) {
    Serial.println("MMA8451 (Accelerometer) failed to initialise.");
    while (1);
  }

  Serial.println("Accelerometer Functioning");
  // Setting accelerometer range to 2G
  mma.setRange(MMA8451_RANGE_2_G);

  // Setting flexometer input pin
  pinMode(FLEX_PIN, INPUT);

  // Setting up the BAUD for bluetooth output
  mySerial.begin(9600);

}

void loop() {
  
   // ACCELEROMETER
   mma.read();
   sensors_event_t event;
   mma.getEvent(&event);
   
   // Storing acceleration data in an array (x, y, z)
   double acceleration[3] = {event.acceleration.x, event.acceleration.y, event.acceleration.z };
   
   // Getting orientation value
   uint8_t o = mma.getOrientation();
   double orientation_num;
   
   String orientation;
   
   switch (o) {
     case MMA8451_PL_PUF: 
       orientation = "PUF";
       orientation_num = 1;
       break;
     case MMA8451_PL_PUB: 
       orientation = "PUB";
       orientation_num = 2;
       break;    
     case MMA8451_PL_PDF: 
       orientation = "PDF";
       orientation_num = 3;
       break;
     case MMA8451_PL_PDB: 
       orientation = "PDB";
       orientation_num = 4;
       break;
     case MMA8451_PL_LRF: 
       orientation = "LRF";
       orientation_num = 5;
       break;
     case MMA8451_PL_LRB: 
       orientation = "LRB";
       orientation_num = 6;
       break;
     case MMA8451_PL_LLF: 
       orientation = "LLF";
       orientation_num = 7;
       break;
     case MMA8451_PL_LLB: 
       orientation = "LLB";
       orientation_num = 8;
       break;
    };

    // FLEXOR
    // Reading current from flex pin (ADC)
    int flexADC = analogRead(FLEX_PIN);
    // Voltage
    float flexV = flexADC * VCC / 1023.0;
    // Resistance in ohms
    float flexR = R_DIV * (VCC / flexV - 1.0);
    // Curvature of device in degrees (bend away from white side)
    float angle = map(flexR, STRAIGHT_RESISTANCE, BEND_RESISTANCE, 0, 90.0);

    /*
    // Printing data to serial monitor
    Serial.println("Accelerometer:");
    Serial.print(acceleration[0]);
    Serial.print(", ");
    Serial.print(acceleration[1]);
    Serial.print(", ");
    Serial.println(acceleration[2]);
    Serial.println(orientation);
    Serial.println("Flexometer:");
    Serial.print(angle);
    Serial.println(" degrees");
    */
    // Package data
    double data_package[5] = {acceleration[0], acceleration[1], acceleration[2], orientation_num, angle};
    /*
    // Printing data to bluetooth (highly inefficient)
    mySerial.println("Acceleration: ");
    delay(50);
    mySerial.println(acceleration[0]);
    delay(50);
    mySerial.println(acceleration[1]);
    delay(50);
    mySerial.println(acceleration[2]);
    delay(50);
    mySerial.println("Orientation: ");
    mySerial.println(orientation);
    delay(50);
    mySerial.println("Angle: ");
    mySerial.println(angle);
    delay(50);
    */
    
    // Printing with HEX (fast)
    mySerial.println('\n');
    mySerial.println(acceleration[0]);
    mySerial.println(acceleration[1]);
    mySerial.println(acceleration[2]);
    mySerial.println(orientation_num);
    mySerial.println(angle);
    
    delay(500);

}

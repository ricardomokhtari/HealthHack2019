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


void setup() {
  Serial.begin(9600);

  // Checking Accelerometer is working
  if (! mma.begin()) {
    Serial.println("MMA8451 (Accelerometer) failed to initialise.");
    while (1);
  }

  Serial.println("Accelerometer Functioning");
  Serial.print("Range = "); Serial.print(2 << mma.getRange());  
  Serial.println("G");
  // Setting accelerometer range to 2G
  mma.setRange(MMA8451_RANGE_2_G);

  // Flexor input setup
  pinMode(FLEX_PIN, INPUT);

}

void loop() {
   // ACCELEROMETER
   mma.read();
   sensors_event_t event;
   mma.getEvent(&event);
 
   double acceleration[3] = {event.acceleration.x, event.acceleration.y, event.acceleration.z };

   uint8_t o = mma.getOrientation();

   String orientation;
   switch (o) {
     case MMA8451_PL_PUF: 
       orientation = "Portrait Up Front";
       break;
     case MMA8451_PL_PUB: 
       orientation = "Portrait Up Back";
       break;    
     case MMA8451_PL_PDF: 
       orientation = "Portrait Down Front";
       break;
     case MMA8451_PL_PDB: 
       orientation = "Portrait Down Back";
       break;
     case MMA8451_PL_LRF: 
       orientation = "Landscape Right Front";
       break;
     case MMA8451_PL_LRB: 
       orientation = "Landscape Right Back";
       break;
     case MMA8451_PL_LLF: 
       orientation = "Landscape Left Front";
       break;
     case MMA8451_PL_LLB: 
       orientation = "Landscape Left Back";
       break;
    };

    // FLEXOR
    int flexADC = analogRead(FLEX_PIN);
    float flexV = flexADC * VCC / 1023.0;
    // Resistance in ohms
    float flexR = R_DIV * (VCC / flexV - 1.0);
    // Curvature of device in degrees
    float angle = map(flexR, STRAIGHT_RESISTANCE, BEND_RESISTANCE, 0, 90.0);


    // Print data
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
    delay(500);
}

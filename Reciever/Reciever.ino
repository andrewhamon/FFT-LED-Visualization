#include <Adafruit_NeoPixel.h>


#define stripLength 60
#define ledStripPin 6

// Initialize LED strip
Adafruit_NeoPixel myStrip = Adafruit_NeoPixel(stripLength, ledStripPin, NEO_GRB + NEO_KHZ800);
byte n;
byte k;
byte colors[3];
boolean pinOn = false;

void setup(){
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  n = 0;
  k = 0;
  myStrip.begin();
  myStrip.show();
}

void serialEvent(){

  while(Serial.available()){
    pinOn = !pinOn;

    byte x = Serial.read();

    // If end-of-frame code recieved
    if(x == 254){
      myStrip.setBrightness(64);
      myStrip.show();
      // Reset counters
      k = 0;
      n = 0;
    }
    else{
      // Data is sent R,G,B,R,G,B etc so we must
      // accumulate and entire RGB triplet before
      // writing to the LED strip
      colors[k] = x;
      k+= 1;
      if(k > 2){
        myStrip.setPixelColor(n, colors[0], colors[1], colors[2]);
        k = 0;
        n += 1;
      }
    }
  }
}


void loop(){
  if(pinOn){
    digitalWrite(13, HIGH);
  }
  else{
    digitalWrite(13, LOW);
  }
  // Empty loop because sketch is entirely serial even driven
}
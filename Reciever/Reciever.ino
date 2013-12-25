#include <Adafruit_NeoPixel.h>


#define stripLength 60
#define ledStripPin 6

// Initialize LED strip
Adafruit_NeoPixel myStrip = Adafruit_NeoPixel(stripLength, ledStripPin, NEO_GRB + NEO_KHZ800);
byte n;
byte k;
byte colors[3];

void setup(){
  Serial.begin(115200);
  n = 0;
  k = 0;
  myStrip.begin();
  myStrip.show();
}

void serialEvent(){

  while(Serial.available()){

    char x = Serial.read();

    // If end-of-frame code recieved
    if(x == 255 || x > 59){
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
      n += 1;
      if(k > 2){
        myStrip.setPixelColor(n, colors[0], colors[1], colors[2]);
        k = 0;
      }
    }
  }
}


void loop(){
  // Empty loop because sketch is entirely serial even driven
}
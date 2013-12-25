import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
FFT fft;

Strip myStrip1;

int ledStripLength;

History fftHistory;
History logHistory;
History logHistory2;
History stripHistory; //keep various rolling averages for different purposes

Histogram histogram;

float[] prevSpec;
float[] currentSpec;
float[] currentLogSpec;
float[] stripValues;
float[] max;

float multiplier;
float multiplier2;

long hue;
long hueOffset;

int frames;

int windowOffset;
PShader blur;

int loopCount;

boolean needUpdate;

void setup() {
  
  frameRate(1000);
  size(1440, 300, OPENGL);
  smooth();
  
  ledStripLength = 120;
  
  hueOffset = int(random(255));
  println(hueOffset);
   
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024, 44100);
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(11, 30);
  
  fft.forward(in.mix);
  
  myStrip1 = new Strip(ledStripLength, 0, width/(2*ledStripLength), height-width/(2*ledStripLength), width-(width/(2*ledStripLength)), height-width/(2*ledStripLength));
  
  fftHistory = new History(fft.specSize(), 12);
  logHistory = new History(fft.avgSize(), 2);
  logHistory2 = new History(fft.avgSize(), 256);
  stripHistory = new History(ledStripLength, 24);
  
  histogram = new Histogram(100, 0, 1124, 0, fft.avgSize(), -100);
  
  prevSpec = new float[fft.specSize()];
  currentSpec = new float[fft.specSize()];
  currentLogSpec = new float[fft.avgSize()]; //for easy, cheap access to data which will be accessed multiple times. Also for use with the History addData() method which requires a float[] array
  max = new float[fft.specSize()]; //max values for the graphic equalizer
  
  windowOffset = 0;
  
  stripValues = new float[ledStripLength];
  
  frames = 0;
  
  ellipseMode(CENTER);
  
  textSize(16);
}

// void draw() {
//   fft.forward(in.mix); //performs a fourier transformation on the mix channel (L and R combined)
//   for(int i = 0; i < fft.specSize(); i++){
//     currentSpec[i] = fft.getBand(i);
//   }
  
//   needUpdate = false;
  
//   for(int i = 0; i < fft.specSize(); i++){
//     if(currentSpec[i] != prevSpec[i]){
//       needUpdate = true;
//     }
//     prevSpec[i] = currentSpec[i];
//   }
  

//   if(needUpdate){
//     println("hi");
//     update1();
//   }
    
  
// }

void draw(){
   needUpdate = false;
   loopCount = 0;
   while(!needUpdate){
    fft.forward(in.mix); //performs a fourier transformation on the mix channel (L and R combined)
    for(int i = 0; i < fft.specSize(); i++){
      currentSpec[i] = fft.getBand(i);
    }
    for(int i = 0; i < fft.specSize(); i++){
      if(currentSpec[i] != prevSpec[i]){
        needUpdate = true;
      }
    prevSpec[i] = currentSpec[i];
    }
    loopCount += 1;
  }

  fftHistory.addData(currentSpec);
    
  background(#000000);
  
  hue = (hueOffset + frameCount/10)%256;
  
  multiplier = 3*sq(mouseX)/float(width); //X position adjusts scale factor for all light values
  multiplier2 = mouseY*5/float(height); //Y position adjusts how fast light drops off
  
  colorMode(HSB, 255, 255, 255, 255);
  fill(hue, 255, 255);
  text(multiplier, 1, 16);
  text(multiplier2, 1, 32); //for easy viewing of the two multipliers
  text(loopCount, 1, 80);
  

  histogram.addData(currentLogSpec);
  histogram.draw();
  

  for(int i = 0; i < fft.avgSize(); i++){
    currentLogSpec[i] = fft.getAvg(i);
  }
  
  logHistory.addData(currentLogSpec);
  logHistory2.addData(currentLogSpec);
  
  
  strokeWeight(2); 
  stroke(hue, 128, 200);
  
  strokeWeight(0);
  
  colorMode(HSB, 255, 1.0, pow(256, multiplier2));
  
  for(int i = 0; i < ledStripLength; i++){
    myStrip1.setColor(i, color(hue, 1.0 - (logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75), multiplier*pow(logHistory.getAvg(i+windowOffset), multiplier2)));
    // myStrip1.setColor(i, color(hue, logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75, logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75));

  }


  
  colorMode(HSB, 255, 255, 255);
  for(int i = 0; i < ledStripLength; i++){
    stripValues[i] = brightness(myStrip1.getColor(i));
  }
  
  stripHistory.addData(stripValues);
  
  text(frameRate, 1, 48);
  text(float(windowOffset), 1, 64);
  
  myStrip1.draw();
}
  
 
void stop(){
  //close the AudioPlayer you got from Minim.loadFile()
    in.close();
  
    minim.stop();
 
  //this calls the stop method that 
  //you are overriding by defining your own
  //it must be called so that your application 
  //can do all the cleanup it would normally do
    super.stop();
}

class Strip{
  int numLeds;
  float diameter;
  
  float xstart;
  float xend;
  float ystart;
  float yend;
  float xlength;
  float ylength;
  
  color[] colors;
  float[][] centers;
  
  Strip(int stripLength, float ledSize, float x0, float y0, float x1, float y1){
    float lineLength = sqrt(sq(x1-x0) + sq(y1-y0));
    if(ledSize == 0 || ledSize > lineLength/(stripLength-1)){
      ledSize = lineLength/(stripLength-1);
    } 
    numLeds = stripLength;
    diameter = ledSize;
    xstart = x0;
    xend = x1;
    xlength = x1 - x0;
    ylength = y1 - y0;
    ystart = y0;
    yend = y1;
    colors = new color[numLeds];
    centers = new float[numLeds][2];
    
    for(int i = 0; i < numLeds; i++){
      centers[i][0] = (xstart + (xlength/(numLeds-1))*i);
      centers[i][1] = (ystart + (ylength/numLeds)*i);
    }
  }
    public void setColor(int led, color c){
      colors[led] = c;
    }
    
    public void clearStrip(){
      for(int i = 0; i < numLeds; i++){
        colors[i] = color(0);
      }
    }
    
    public color getColor(int led){
      return colors[led];
    }
    
    public void draw(){
      noStroke();
      for(int i = 0; i < numLeds; i++){
        fill(colors[i]);
        ellipse(centers[i][0], centers[i][1], diameter, diameter);
      }
    }
}
  
class History{
  float[][] history;
  float[] avg;
  int size;
  int time;
  
  History(int tmpsize, int tmptime){
    size = tmpsize;
    time = tmptime;
    history = new float[time][size];
    avg = new float[size];
  }
  
  void shiftHistory(){
    for( int h = (time - 1); h > 0; --h ) {
      for( int i = 0; i < size; i++ ) {
        if( h == (time - 1)){
          avg[i] -= history[h][i];
        }
        history[h][i] = history[h-1][i];
      }
    }
  }
  
  void addData(float[] tmp){
    shiftHistory();
    for(int i = 0; i < size; i++){
      history[0][i] = tmp[i];
      avg[i] += tmp[i];
    }
  }
  
  float getAvg(int i){
    return avg[i]/time;
  }

  float[] getAvgArray(){
    float[] tmp = new float[size];
    for(int i = 0; i < size; i++){
      tmp[i] = avg[i]/time;
    }
    return tmp;
  }
}

float getMean(float[] list){
  float sum = 0;
  for(int i = 0; i < list.length; i++){
    sum += list[i];
  }
  return sum/list.length;
}

float getVariance(float[] list){
  float mean = getMean(list);
  float sum = 0;
  for(int i = 0; i < list.length; i++){
    sum += sq(list[i] - mean);
  }
  return sum/list.length;
}

void mouseWheel(MouseEvent event) {

  windowOffset += event.getAmount();
  if(windowOffset < 0){
    windowOffset = 0;
  }
  if(windowOffset + ledStripLength > fft.avgSize()){
    windowOffset = fft.avgSize() - (ledStripLength);
  }
}

class Histogram{
  
  float[] max;
  float[] inData;
  float[][] corners;
  int size;
  float barWidth;
  float xstart;
  float ystart;
  float xend;
  float yend;
  
  float xdiff;
  float ydiff;
  
  float xdir;
  float ydir;
  
  float sign;
  
  float scaleFactor;
  
  Histogram(float x0, float y0, float x1, float y1, int numBands, float scale){
    max = new float[numBands];
    inData = new float[numBands];
    corners = new float[numBands][2];
    
    size = numBands;
    
    xstart = x0;
    xend = x1;
    ystart = y0;
    yend = y1;
    
    xdiff = x1 - x0;
    ydiff = y1 - y0;
    
    
    barWidth = sqrt(sq(xdiff) + sq(ydiff))/numBands;
    
    scaleFactor = scale;
    
    for(int i = 0; i < numBands; i++){
      corners[i][0] = xstart + (i*xdiff/numBands);
      corners[i][1] = ystart + (i*ydiff/numBands);
    }
    
    xdir = 0;
    ydir = 0;
    
    if(xdiff == 0 && ydiff > 0){
      xdir = -1;
      ydir = 0;
    }
    if(xdiff == 0 && ydiff < 0){
      xdir = 1;
      ydir = 0;
    }
    if(xdiff > 0 && ydiff == 0){
      xdir = 0;
      ydir = -1;
    }
    if(xdiff < 0 && ydiff == 0){
      xdir = 0;
      ydir = 1;
    }
    if(xdiff != 0 && ydiff !=0){
      if(xdiff > 0){
        ydir = -1.0;
      }
      if(xdiff < 0){
        ydir = 1.0;
      }
        
      xdir = -1*ydir*ydiff/xdiff;
    }
    
    float tmplength = sqrt(sq(xdir) + sq(ydir));
    xdir /= tmplength;
    ydir /= tmplength;
  }
    
    public void addData(float[] tmp){
      inData = tmp;
    }
    
    public void draw(){
      strokeWeight(barWidth);
      stroke(hue, 255, 255);
      for(int i = 0; i < size; i++){
        line(corners[i][0], corners[i][1], scaleFactor*inData[i]*xdir + corners[i][0], scaleFactor*inData[i]*ydir + corners[i][1]);
      }
    }
}

boolean sketchFullScreen() {
  return true;
}

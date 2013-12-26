import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class EQ extends PApplet {

// For audio buffers and FFT



// For Arduino communication via serial


// See Globals.pde for list of global variables used


public void setup() {
  size(1440, 900, P2D);
  smooth();

  arduinoLED = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  
  // Starting hue is different each time program starts
  hueOffset = PApplet.parseInt(random(255));
  
  // Initialize minim, line in, FFT class
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024, 30720); // 30720
  fft = new FFT(in.bufferSize(), in.sampleRate());

  // Creates log spaced averages
  // first param is size of initial octave
  // second param is how many averages per octave
  fft.logAverages(11, 12);
  
  // Initialize LED strip object for simulating Arduino LED strip
  // See Strip.pde to examine Strip class
  ledStripLength = 60;
  myStrip1 = new Strip(ledStripLength, 0, width/(2*ledStripLength), height-width/(2*ledStripLength), width-(width/(2*ledStripLength)), height-width/(2*ledStripLength));
  
  // Initialize history objects to keep various rolling averages
  // See History.pde to examine History class
  fftHistory = new History(fft.specSize(), 12);
  logHistory = new History(fft.avgSize(), 3);
  logHistory2 = new History(fft.avgSize(), 30);

  // Initialize histogram object to display histogram on screen
  // See Histogram.pde to examine Histogram and HistogramWeb Class
  histogram = new HistogramWeb(0.0f, 0.0f, width, 0.00f, fft.avgSize(), -50.0f, 4);
  
  // For convenient access throught sketch
  prevSpec = new float[fft.specSize()];
  currentSpec = new float[fft.specSize()];
  currentLogSpec = new float[fft.avgSize()];
  
  // For "scrolling" the LED "window" left or right
  // one LED Strip can't show full spectrum at a time
  // see mouseWheel function below
  windowOffset = 0;

  scaleMultiplier = 0;
  expMultiplier = 0;
  
  textSize(16);
}

public void draw(){

  loopCount = 0;

   // Perform a fourier transformation on the mix channel (L and R combined)
   // checks if current FFT is same or different than previous
   // if new, updates values of currentSpec[] and exits loop
   // blocks main loop indefinitely if no audio
   needUpdate = false;
   while(!needUpdate && loopCount < 1000){
    fft.forward(in.mix);
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

  // Updates values of currentLogSpec[]
  for(int i = 0; i < fft.avgSize(); i++){
    currentLogSpec[i] = fft.getAvg(i);
  }

  // Updates various histories
  fftHistory.addData(currentSpec);
  logHistory.addData(currentLogSpec);
  logHistory2.addData(currentLogSpec);

  // Hue loops though color wheel with time
  hue = (hueOffset + frameCount/10)%256;

  // X position adjusts scale factor for all light values
  // Y position adjusts how fast light drops off

  if(mousePressed){
  scaleMultiplier = 3*sq(mouseX)/PApplet.parseFloat(width);
  expMultiplier = mouseY*5/PApplet.parseFloat(height);
}

  // Updates histogram 
  histogram.addData(currentLogSpec);

  
  colorMode(HSB, 255, 1.0f, pow(256, expMultiplier));
  for(int i = 0; i < ledStripLength; i++){
    myStrip1.setColor(i, color(hue, (logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75f), scaleMultiplier*pow(logHistory.getAvg(i+windowOffset), expMultiplier)));
  }

  colorMode(HSB, 255, 255, 255);
  fill(hue, 255, 255);
  stroke(hue, 255, 255);

  // Redraw background each frame  
  background(0xff000000);

  // Debugging
  text(scaleMultiplier, 1, 16);
  text(expMultiplier, 1, 32);
  text(frameRate, 1, 48);
  text(PApplet.parseFloat(windowOffset), 1, 64);
  
  // Draws LED strip
  myStrip1.draw();
  myStrip1.arduinoWrite(arduinoLED);

  // Draws histogram
  histogram.draw();

}
  
 
public void stop(){
  // close the AudioPlayer you got from Minim.loadFile()
  in.close();
  
  minim.stop();
 
  // This calls the stop method that 
  // you are overriding by defining your own
  // it must be called so that your application 
  // can do all the cleanup it would normally do
  super.stop();
}

// Adjust LED "Window" using mouse wheel or trackpad scrolling
public void mouseWheel(MouseEvent event) {

  windowOffset += event.getAmount();
  if(windowOffset < 0){
    windowOffset = 0;
  }
  if(windowOffset + ledStripLength > fft.avgSize()){
    windowOffset = fft.avgSize() - (ledStripLength);
  }
}
//These are no longer being used
//Shall be completely removed after
//A while

// float getMean(float[] list){
//   float sum = 0;
//   for(int i = 0; i < list.length; i++){
//     sum += list[i];
//   }
//   return sum/list.length;
// }

// float getVariance(float[] list){
//   float mean = getMean(list);
//   float sum = 0;
//   for(int i = 0; i < list.length; i++){
//     sum += sq(list[i] - mean);
//   }
//   return sum/list.length;
// }


//Work in progress
Minim minim;
AudioInput in;
FFT fft;

Serial arduinoLED;

int ledStripLength;

Strip myStrip1;

History fftHistory;
History logHistory;
History logHistory2;

HistogramWeb histogram;

float scaleMultiplier;
float expMultiplier;

long hue;

long hueOffset;

int windowOffset;

boolean needUpdate;

float[] prevSpec;
float[] currentSpec;
float[] currentLogSpec;

int loopCount;
class Histogram{
  float[][] corners;
  int size_; //avoid naming things the same as built in functions
  float barWidth;
  float xstart;
  float ystart;
  float xend;
  float yend;
  
  float xdiff;
  float ydiff;
  
  float xdir;
  float ydir;
  
  float scaleFactor;

  History timeAvg;
  
  Histogram(float x0, float y0, float x1, float y1, int numBands, float scale, int historyLength){

    //For bottom left corner of each bar
    corners = new float[numBands][2];
    
    size_ = numBands;

    timeAvg = new History(size_, historyLength);
    
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
        ydir = -1.0f;
      }
      if(xdiff < 0){
        ydir = 1.0f;
      }
        
      xdir = -1*ydir*ydiff/xdiff;
    }
    
    float tmplength = sqrt(sq(xdir) + sq(ydir));
    xdir /= tmplength;
    ydir /= tmplength;
  }
    
    public void addData(float[] tmp){
      timeAvg.addData(tmp);
    }
    
    public void draw(){
      strokeWeight(barWidth);
      stroke(hue, 255, 255);
      for(int i = 0; i < size_; i++){
        line(corners[i][0], corners[i][1], scaleFactor*timeAvg.getAvg(i)*xdir + corners[i][0], scaleFactor*timeAvg.getAvg(i)*ydir + corners[i][1]);
      }
    }
}

class HistogramWeb{
  
  float[] max;
  float[][] corners;
  float[][] points;
  int size_;
  float barWidth;
  float xstart;
  float ystart;
  float xend;
  float yend;
  
  float xdiff;
  float ydiff;
  
  float xdir;
  float ydir;
  
  float scaleFactor;

  History timeAvg;
  
  HistogramWeb(float x0, float y0, float x1, float y1, int numBands, float scale, int historyLength){
    max = new float[numBands];
    corners = new float[numBands][2];
    points = new float[numBands][2];
    
    size_ = numBands;

    timeAvg = new History(size_, historyLength);
    
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
        ydir = -1.0f;
      }
      if(xdiff < 0){
        ydir = 1.0f;
      }
        
      xdir = -1*ydir*ydiff/xdiff;
    }
    
    float tmplength = sqrt(sq(xdir) + sq(ydir));
    xdir /= tmplength;
    ydir /= tmplength;
  }
    
    public void addData(float[] tmp){
      timeAvg.addData(tmp);
    }
    
    public void draw(){
      strokeWeight(1);
      stroke(hue, 255, 255);
      beginShape();
      colorMode(HSB, 255);
      fill(0, 0, 0, 0);
      vertex(xstart, ystart);
      for(int i = 0; i < size_; i++){
        // line(corners[i][0], corners[i][1], scaleFactor*timeAvg.getAvg(i)*xdir + corners[i][0], scaleFactor*timeAvg.getAvg(i)*ydir + corners[i][1]);
        points[i][0] = scaleFactor*timeAvg.getAvg(i)*xdir + corners[i][0];
        points[i][1] = scaleFactor*timeAvg.getAvg(i)*ydir + corners[i][1];
        if(i != 0){
          stroke(hue, 100*timeAvg.getAvg(i), 255);
          fill(hue, 255, 255, 15*timeAvg.getAvg(i));
          vertex(points[i][0] + barWidth/2.0f, points[i][1]);
        }
      }
      fill(0, 0, 0, 0);
      vertex(xend, yend);
      endShape();
    }
}

public boolean sketchFullScreen() {
  return true;
}
class History{
  float[][] history;
  float[] avg;
  int size;
  int time;
  
  //Creates a history buffer for length time for
  //a buffer of size size
  History(int tmpsize, int tmptime){
    size = tmpsize;
    time = tmptime;
    history = new float[time][size];

    //doesn't actually contain the average
    //but the running total
    avg = new float[size];
  }
  
  //Shift out the oldest entry before shifting in new data
  public void shiftHistory(){
    for( int h = (time - 1); h > 0; --h ) {
      for( int i = 0; i < size; i++ ) {
        if( h == (time - 1)){
          //subtract oldest data from rollling total
          avg[i] -= history[h][i];
        }
        history[h][i] = history[h-1][i];
      }
    }
  }
  
  //Add a new entry/array
  public void addData(float[] tmp){
    shiftHistory();
    for(int i = 0; i < size; i++){
      history[0][i] = tmp[i];
      avg[i] += tmp[i];
    }
  }
  
  //Return the running average for the ith element
  public float getAvg(int i){
    return avg[i]/time;
  }

  //Return array containing all running averages
  public float[] getAvgArray(){
    float[] tmp = new float[size];
    for(int i = 0; i < size; i++){
      tmp[i] = avg[i]/time;
    }
    return tmp;
  }
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
  
  int[] colors;
  float[][] centers;


  //Draws led strip from (x0, y0) to (x1, y1)
  Strip(int stripLength, float ledSize, float x0, float y0, float x1, float y1){

    //Catches too large a daimeter or picks a defualt if left at 0
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
    colors = new int[numLeds];
    centers = new float[numLeds][2];
    
    //Finds centers of each LED
    for(int i = 0; i < numLeds; i++){
      centers[i][0] = (xstart + (xlength/(numLeds-1))*i);
      centers[i][1] = (ystart + (ylength/numLeds)*i);
    }
  }

  //Sets color of an individual LED
  public void setColor(int led, int c){
    colors[led] = c;
  }
  
  //Resets all colors to off (black)
  public void clearStrip(){
    for(int i = 0; i < numLeds; i++){
      colors[i] = color(0);
    }
  }
  
  //Retrieves color (of type Color) of an indifidual LED
  //Use red(stripName.getColor(i)) to get red value, etc.
  public int getColor(int led){
    return colors[led];
  }
  
  //Draws the strip to the window
  public void draw(){
    noStroke();
    for(int i = 0; i < numLeds; i++){
      fill(colors[i]);
      ellipse(centers[i][0], centers[i][1], diameter, diameter);
    }
  }

  public void arduinoWrite(Serial mySerial){
    byte eof = PApplet.parseByte(254);
    //254 because the full byte 255 is sent to indicate end of frame transmission
    colorMode(RGB, 253, 253, 253);
    byte r;
    byte g;
    byte b;
    for(int i = (numLeds-1); i >= 0; i--){
      r = PApplet.parseByte(red(colors[i]));
      g = PApplet.parseByte(blue(colors[i]));
      b = PApplet.parseByte(green(colors[i]));
      mySerial.write(r);
      mySerial.write(b);
      mySerial.write(g);
    }
    mySerial.write(eof); //Signal to arduino that all data for current frame has been sent
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "EQ" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

// :::::::::::::::::::::::: LICENSE AND COPYRIGHT NOTICE :::::::::::::::::::::::
// Copyright (c) 2013 Andrew Hamon.  All rights reserved.
// 
// This file is part of FFT-LED-Visualization.  FFT-LED-Visualization is
// distributed under the MIT License.  You can read the full terms of use in the
// LICENSE file, or online at http://opensource.org/licenses/MIT.
// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

// For audio buffers and FFT
import ddf.minim.*;
import ddf.minim.analysis.*;

// For Arduino communication via serial
import processing.serial.*;

// See Globals.pde for list of global variables used


void setup() {
  size(1440, 900, P2D);
  smooth();

  try {
    arduinoLED = new Serial(this, "/dev/tty.usbmodem1421", 115200);
    serialConnected = true;
  }
  catch (Exception e) {
    serialConnected = false;
    
  }

  
  // Starting hue is different each time program starts
  hueOffset = int(random(255));
  
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
  myStrip1 = new Strip(ledStripLength, 0, width/(2*ledStripLength), height/2.0, width-(width/(2*ledStripLength)), height/2.0);
  
  // Initialize history objects to keep various rolling averages
  // See History.pde to examine History class
  fftHistory = new History(fft.specSize(), 12);
  logHistory = new History(fft.avgSize(), 3);
  logHistory2 = new History(fft.avgSize(), 30);

  // Initialize histogram object to display histogram on screen
  // See Histogram.pde to examine Histogram and HistogramWeb Class
  histogram = new HistogramWeb(0.0, height/2.0 + 12, width, height/2.0 + 12, fft.avgSize(), -20.0, 3);
  histogram2 = new HistogramWeb(0.0, height/2.0 - 12, width, height/2.0 - 12, fft.avgSize(), 20.0, 3);
  histogramMode = true;
  
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

void draw(){

  loopCount = 0;

   // Perform a fourier transformation on the mix channel (L and R combined)
   // checks if current FFT is same or different than previous
   // if new, updates values of currentSpec[] and exits loop
   // loopCount prevents blocking for too long
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
  scaleMultiplier = 3*sq(mouseX)/float(width);
  expMultiplier = mouseY*5/float(height);
}

  // Updates histogram 
  histogram.addData(currentLogSpec);
  histogram2.addData(currentLogSpec);

  
  colorMode(HSB, 255, 1.0, pow(256, expMultiplier));
  for(int i = 0; i < ledStripLength; i++){
    myStrip1.setColor(i, color(hue, (logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75), scaleMultiplier*pow(logHistory.getAvg(i+windowOffset), expMultiplier)));
  }

  colorMode(HSB, 255, 255, 255);
  fill(hue, 255, 255);
  stroke(hue, 255, 255);

  // Redraw background each frame  
  background(#000000);

  // Debugging
  text(scaleMultiplier, 1, 16);
  text(expMultiplier, 1, 32);
  text(frameRate, 1, 48);
  text(float(windowOffset), 1, 64);
  
  // Draws LED strip
  myStrip1.draw();

  if(serialConnected){
  myStrip1.arduinoWrite(arduinoLED);
}

  // Draws histogram
  histogram.draw();
  histogram2.draw();

}
  
 
void stop(){
  // close the AudioPlayer you got from Minim.loadFile()
  in.close();
  
  minim.stop();
 
  // This calls the stop method that 
  // you are overriding by defining your own
  // it must be called so that your application 
  // can do all the cleanup it would normally do
  super.stop();
}

boolean sketchFullScreen() {
  return true;
}

// Adjust LED "Window" using mouse wheel or trackpad scrolling
void mouseWheel(MouseEvent event) {

  windowOffset += event.getAmount();
  if(windowOffset < 0){
    windowOffset = 0;
  }
  if(windowOffset + ledStripLength > fft.avgSize()){
    windowOffset = fft.avgSize() - (ledStripLength);
  }
}

void keyPressed() {
  if (key == ' '){
    histogramMode = !histogramMode;
  }
}
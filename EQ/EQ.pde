//For audio buffers and FFT
import ddf.minim.*;
import ddf.minim.analysis.*;
//For Arduino communication via serial
import processing.serial.*;

//See Globals.pde for list of global variables used


void setup() {
  size(1440, 900, OPENGL);
  smooth();
  
  //Starting hue is different each time program starts
  hueOffset = int(random(255));
  
  //Initialize minim, line in, FFT class
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024, 30720); //30720
  fft = new FFT(in.bufferSize(), in.sampleRate());

  //Creates log spaced averages
  //First param is size of initial octave
  //Second param is how many averages per octave
  fft.logAverages(11, 12);
  
  //Initialize LED strip object for simulating Arduino LED strip
  //See Strip.pde to examine Strip class
  ledStripLength = fft.avgSize();
  myStrip1 = new Strip(fft.avgSize(), 0, width/(2*ledStripLength), height-width/(2*ledStripLength), width-(width/(2*ledStripLength)), height-width/(2*ledStripLength));
  
  //Initialize history objects to keep various rolling averages
  //See History.pde to examine History class
  fftHistory = new History(fft.specSize(), 12);
  logHistory = new History(fft.avgSize(), 2);
  logHistory2 = new History(fft.avgSize(), 7);

  //Initialize histogram object to display histogram on screen
  //See Histogram.pde to examine Histogram and HistogramWeb Class
  histogram = new HistogramWeb(0.0, 0.0, float(width), 0.00, fft.avgSize(), -60.0, 3);
  
  //For convenient access throught sketch
  prevSpec = new float[fft.specSize()];
  currentSpec = new float[fft.specSize()];
  currentLogSpec = new float[fft.avgSize()];
  
  //For "scrolling" the LED "window" left or right
  //One LED Strip can't show full spectrum at a time
  //See mouseWheel function below
  windowOffset = 0;
  
  textSize(16);
}

void draw(){

   //perform a fourier transformation on the mix channel (L and R combined)
   //Checks if current FFT is same or different than previous
   //If new, updates values of currentSpec[] and exits loop
   //Blocks main loop indefinitely if no audio
   needUpdate = false;
   while(!needUpdate){
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
  }

  //Updates values of currentLogSpec[]
  for(int i = 0; i < fft.avgSize(); i++){
    currentLogSpec[i] = fft.getAvg(i);
  }

  //Updates various histories
  fftHistory.addData(currentSpec);
  logHistory.addData(currentLogSpec);
  logHistory2.addData(currentLogSpec);

  //Hue loops though color wheel with time
  hue = (hueOffset + frameCount/10)%256;

  // X position adjusts scale factor for all light values
  // Y position adjusts how fast light drops off
  scaleMultiplier = 3*sq(mouseX)/float(width);
  expMultiplier = mouseY*5/float(height);

  //Updates histogram 
  histogram.addData(currentLogSpec);

  
  colorMode(HSB, 255, 1.0, pow(256, expMultiplier));
  for(int i = 0; i < ledStripLength; i++){
    myStrip1.setColor(i, color(hue, 1.0 - (logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75), scaleMultiplier*pow(logHistory.getAvg(i+windowOffset), expMultiplier)));
  }

  colorMode(HSB, 255, 255, 255);
  fill(hue, 255, 255);
  stroke(hue, 255, 255);

  //Redraw background each frame  
  background(#000000);

  //Debugging
  text(scaleMultiplier, 1, 16);
  text(expMultiplier, 1, 32);
  text(frameRate, 1, 48);
  text(float(windowOffset), 1, 64);
  
  //Draws LED strip
  myStrip1.draw();

  //Draws histogram
  histogram.draw();

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

//Adjust LED "Window" using mouse wheel or trackpad scrolling
void mouseWheel(MouseEvent event) {

  windowOffset += event.getAmount();
  if(windowOffset < 0){
    windowOffset = 0;
  }
  if(windowOffset + ledStripLength > fft.avgSize()){
    windowOffset = fft.avgSize() - (ledStripLength);
  }
}
import ddf.minim.*;
import ddf.minim.analysis.*;

void setup() {
  
  frameRate(1000);
  size(1440, 900, OPENGL);
  smooth();
  
  hueOffset = int(random(255));
   
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024, 30720); //30720
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(11, 12);
  
  fft.forward(in.mix);
  
  ledStripLength = fft.avgSize();
  myStrip1 = new Strip(fft.avgSize(), 0, width/(2*ledStripLength), height-width/(2*ledStripLength), width-(width/(2*ledStripLength)), height-width/(2*ledStripLength));
  
  fftHistory = new History(fft.specSize(), 12);
  logHistory = new History(fft.avgSize(), 2);
  logHistory2 = new History(fft.avgSize(), 7);
  stripHistory = new History(ledStripLength, 6);
  
  histogram = new HistogramWeb(0, 0, width, 0, fft.avgSize(), -60, 3);
  
  prevSpec = new float[fft.specSize()];
  currentSpec = new float[fft.specSize()];
  currentLogSpec = new float[fft.avgSize()]; //for easy, cheap access to data which will be accessed multiple times. Also for use with the History addData() method which requires a float[] array
  
  windowOffset = 0;
  
  stripValues = new float[ledStripLength];
  
  frames = 0;
  
  ellipseMode(CENTER);
  
  textSize(16);
}

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

  // X position adjusts scale factor for all light values
  // Y position adjusts how fast light drops off
  scaleMultiplier = 3*sq(mouseX)/float(width);
  expMultiplier = mouseY*5/float(height);
  
  colorMode(HSB, 255, 255, 255, 255);
  fill(hue, 255, 255);
  text(scaleMultiplier, 1, 16);
  text(expMultiplier, 1, 32); //for easy viewing of the two multipliers
  text(loopCount, 1, 80);
  

  for(int i = 0; i < fft.avgSize(); i++){
    currentLogSpec[i] = fft.getAvg(i);
  }

  histogram.addData(currentLogSpec);
  histogram.draw();
  
  logHistory.addData(currentLogSpec);
  logHistory2.addData(currentLogSpec);
  
  
  strokeWeight(2); 
  stroke(hue, 128, 200);
  
  strokeWeight(0);
  
  colorMode(HSB, 255, 1.0, pow(256, expMultiplier));
  
  for(int i = 0; i < ledStripLength; i++){
    myStrip1.setColor(i, color(hue, 1.0 - (logHistory.getAvg(i+windowOffset)/logHistory2.getAvg(i+windowOffset) - 0.75), scaleMultiplier*pow(logHistory.getAvg(i+windowOffset), expMultiplier)));
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

void mouseWheel(MouseEvent event) {

  windowOffset += event.getAmount();
  if(windowOffset < 0){
    windowOffset = 0;
  }
  if(windowOffset + ledStripLength > fft.avgSize()){
    windowOffset = fft.avgSize() - (ledStripLength);
  }
}
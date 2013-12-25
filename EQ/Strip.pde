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
    colors = new color[numLeds];
    centers = new float[numLeds][2];
    
    //Finds centers of each LED
    for(int i = 0; i < numLeds; i++){
      centers[i][0] = (xstart + (xlength/(numLeds-1))*i);
      centers[i][1] = (ystart + (ylength/numLeds)*i);
    }
  }

  //Sets color of an individual LED
  public void setColor(int led, color c){
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
  public color getColor(int led){
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
    byte eof = byte(254);
    //254 because the full byte 255 is sent to indicate end of frame transmission
    colorMode(RGB, 253, 253, 253);
    byte r;
    byte g;
    byte b;
    for(int i = (numLeds-1); i >= 0; i--){
      r = byte(red(colors[i]));
      g = byte(blue(colors[i]));
      b = byte(green(colors[i]));
      mySerial.write(r);
      mySerial.write(b);
      mySerial.write(g);
    }
    mySerial.write(eof); //Signal to arduino that all data for current frame has been sent
  }
}
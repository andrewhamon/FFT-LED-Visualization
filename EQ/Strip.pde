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
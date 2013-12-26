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
          vertex(points[i][0] + barWidth/2.0, points[i][1]);
        }
      }
      fill(0, 0, 0, 0);
      vertex(xend, yend);
      endShape();
    }
}

boolean sketchFullScreen() {
  return true;
}
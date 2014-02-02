// :::::::::::::::::::::::: LICENSE AND COPYRIGHT NOTICE :::::::::::::::::::::::
// Copyright (c) 2013 Andrew Hamon.  All rights reserved.
// 
// This file is part of FFT-LED-Visualization.  FFT-LED-Visualization is
// distributed under the MIT License.  You can read the full terms of use in the
// LICENSE file, or online at http://opensource.org/licenses/MIT.
// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

// :::::::::::::::::::::::: LICENSE AND COPYRIGHT NOTICE :::::::::::::::::::::::
// Copyright (c) 2013 Andrew Hamon.  All rights reserved.
// 
// This file is part of FFT-LED-Visualization.  FFT-LED-Visualization is
// distributed under the MIT License.  You can read the full terms of use in the
// LICENSE file, or online at http://opensource.org/licenses/MIT.
// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class Histogram{
  boolean mode;
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
  float posScaleFactor;

  History timeAvg;
  
  Histogram(float x0, float y0, float x1, float y1, int numBands, float scale,
    int historyLength){

    mode = true;

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

    if(scaleFactor < 0){
      posScaleFactor = -1*scaleFactor;
    }
    else{
      posScaleFactor = scaleFactor;
    }
    
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

  public History getHistory(){
    return timeAvg;
  }

  public void setScale(float x){
    scaleFactor = x;
    if(scaleFactor < 0){
      posScaleFactor = -1*scaleFactor;
    }
  else{
    posScaleFactor = scaleFactor;
    }
  }

  public float getScale(){
    return scaleFactor;
  }
  
  public void draw(){
    strokeWeight(barWidth);
    stroke(hue, 255, 255);
    for(int i = 0; i < size_; i++){
      line(
        corners[i][0], corners[i][1],
        scaleFactor*timeAvg.getAvg(i)*xdir + corners[i][0],
        scaleFactor*timeAvg.getAvg(i)*ydir + corners[i][1]);
    }
  }
  public void changeMode(boolean x){
  mode = x;
  }

  public void changeMode(){
    mode = !mode;
  }
}

class HistogramWeb extends Histogram{
  
  float[][] points;
  boolean mode;
  
  HistogramWeb(float x0, float y0, float x1, float y1, int numBands,
    float scale, int historyLength){

    super(x0, y0, x1, y1, numBands, scale, historyLength);
    points = new float[numBands][2];
    mode = true;
    
  }

    
  public void addData(float[] tmp){
    timeAvg.addData(tmp);
  }

  public void changeMode(boolean x){
    mode = x;
  }

  public void changeMode(){
    mode = !mode;
  }
  
  public void draw(){
    strokeWeight(5);
    stroke(hue, 0, 255, 50);
    beginShape();
    colorMode(HSB, 255);
    fill(0, 0, 0, 0);
    vertex(xstart, ystart);
    for(int i = 0; i < size_; i++){
      points[i][0] = scaleFactor*timeAvg.getAvg(i)*xdir + corners[i][0];
      points[i][1] = scaleFactor*timeAvg.getAvg(i)*ydir + corners[i][1];
      if((i <= windowOffset + ledStripLength && i >= windowOffset)||mode){
        fill(hue, 255, 255, posScaleFactor*timeAvg.getAvg(i)/2);
        stroke(hue, 2*posScaleFactor*timeAvg.getAvg(i), 255,
          posScaleFactor*timeAvg.getAvg(i) + 50);
      }
      else{
        fill(0,0,0,0);
        stroke(0, 0, 90);
      }
      vertex(points[i][0] + barWidth/2.0, points[i][1]);
      }
    fill(0, 0, 0, 0);
    vertex(xend, yend);
    endShape();
  }
}
// :::::::::::::::::::::::: LICENSE AND COPYRIGHT NOTICE :::::::::::::::::::::::
// Copyright (c) 2013 Andrew Hamon.  All rights reserved.
// 
// This file is part of FFT-LED-Visualization.  FFT-LED-Visualization is
// distributed under the MIT License.  You can read the full terms of use in the
// LICENSE file, or online at http://opensource.org/licenses/MIT.
// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
  void shiftHistory(){
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
  void addData(float[] tmp){
    shiftHistory();
    for(int i = 0; i < size; i++){
      history[0][i] = tmp[i];
      avg[i] += tmp[i];
    }
  }
  
  //Return the running average for the ith element
  float getAvg(int i){
    return avg[i]/time;
  }

  //Return array containing all running averages
  float[] getAvgArray(){
    float[] tmp = new float[size];
    for(int i = 0; i < size; i++){
      tmp[i] = avg[i]/time;
    }
    return tmp;
  }
}
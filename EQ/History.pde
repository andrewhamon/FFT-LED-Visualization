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
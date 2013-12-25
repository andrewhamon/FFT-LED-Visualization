float getMean(float[] list){
  float sum = 0;
  for(int i = 0; i < list.length; i++){
    sum += list[i];
  }
  return sum/list.length;
}

float getVariance(float[] list){
  float mean = getMean(list);
  float sum = 0;
  for(int i = 0; i < list.length; i++){
    sum += sq(list[i] - mean);
  }
  return sum/list.length;
}

class spectrum{
  float[] prev;
  float[] current;

  spectrum(int specSize){
    current = new float[specSize];
    prev = new float[specSize];
  }

  boolean isNew(float[] tmpcurrent){
    boolean newData = false;
    for(int i = 0; i < prev.length; i++){
      if(tmpcurrent[i] != prev[i]){
        newData = true;
      }
      prev[i] = tmpcurrent[i];
      }
      return newData;
    }
  }
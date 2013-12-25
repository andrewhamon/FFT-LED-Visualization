Minim minim;
AudioInput in;
FFT fft;

Strip myStrip1;

History fftHistory;
History logHistory;
History logHistory2;
History stripHistory; //keep various rolling averages for different purposes

HistogramWeb histogram;

int ledStripLength;

float[] prevSpec;
float[] currentSpec;
float[] currentLogSpec;
float[] stripValues;

float scaleMultiplier;
float expMultiplier;

long hue;
long hueOffset;

int frames;

int windowOffset;

int loopCount;

boolean needUpdate;
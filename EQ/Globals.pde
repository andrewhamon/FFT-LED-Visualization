Minim minim;
AudioInput in;
FFT fft;

Serial arduinoLED;

int ledStripLength;

Strip myStrip1;

History fftHistory;
History logHistory;
History logHistory2;

HistogramWeb histogram;
HistogramWeb histogram2;

float scaleMultiplier;
float expMultiplier;

long hue;

long hueOffset;

int windowOffset;

boolean needUpdate;

float[] prevSpec;
float[] currentSpec;
float[] currentLogSpec;

int loopCount;

boolean serialConnected;
boolean histogramMode;
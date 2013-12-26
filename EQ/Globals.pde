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
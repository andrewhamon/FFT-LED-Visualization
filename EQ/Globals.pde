// :::::::::::::::::::::::: LICENSE AND COPYRIGHT NOTICE :::::::::::::::::::::::
// Copyright (c) 2013 Andrew Hamon.  All rights reserved.
// 
// This file is part of FFT-LED-Visualization.  FFT-LED-Visualization is
// distributed under the MIT License.  You can read the full terms of use in the
// LICENSE file, or online at http://opensource.org/licenses/MIT.
// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
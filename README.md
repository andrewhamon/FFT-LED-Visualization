FFT-LED-Visualization
=====================

A processing sketch that performs an FFT (using the Minim library) to visualize music on an LED strip (WS2812) controlled via Arduino.

USAGE
=====================
Just run the sketch, and play music. It uses whatever the system default line in is. In OSX I use an app called SoundFlower to create a virtual mic with whatever the system audio is.

I have yet to implement the arduino side of things but I made a "Strip" class which acts as a crude on screen simulation of the LED strip for testing purposes.

Currently the main loop blocks until it detects a change in the FFT, so without music playing the screen should freeze.

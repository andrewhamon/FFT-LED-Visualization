FFT-LED-Visualization
=====================

A processing sketch that performs an FFT (using the Minim library) to visualize music in real time on an LED strip (WS2812) controlled via Arduino.
It also displays a live histogram and a simulation of the LED strip.

Seup
=====================

1. Verify that ledStripLength in EQ.pde (in setup()), stripLength in Reciever.ino, and the length of your actual LED strip are all in agreement.
2. Upload Reciever.ino to your arduino; attach your LED strip to pin 6.
3. Make sure the correct serial port is selected in EQ.pde (in setup()). Currently it is set to "dev/tty.usbmodem1421"
4. Run both sketches!

**If the sketch fails to connect to the specified serial port, it will still run as normal.**

Usage
=====================

You can controll the behavior of the LED strip by clicking in various places on the screen. The Y position of the mouse affects the light fall-off. A higher value (closer to the bottom of the screen) means only really loud parts of the spectrum get through. The X position is a scale factor that is multiplied by each value. A higher X value (more toward the right edge of he screen) makes all the LEDs brighter.

**NB: The constants will only be updated when the mouse is clicked. The current value of the two constants are the top two numbers displayed in the upper left corner of the screen.**

The current framerate is the third number displayed in the upper left corner of the screen.

Because most LED strips will be too short to view all the data at once, you can "scroll" back and forth (using a scroll wheel or two finger swipe if your trackpad supports it). The default position is all the way left (showing the bass end of the spectrum) and the current position is given as the bottom number displayed in the upper left corner (the number is the number of LEDs scrolled to the right; default is 0).
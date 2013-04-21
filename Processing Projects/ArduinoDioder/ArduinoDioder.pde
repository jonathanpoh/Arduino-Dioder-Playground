// Developed by Rajarshi Roy heavily modified by bld @ http://captain-slow.dk/
// http://siliconrepublic.blogspot.com.au/2011/02/arduino-based-pc-ambient-lighting.html
import java.awt.Robot; //java library that lets us take screenshots
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Dimension;
import processing.serial.*; //library for serial communication


Serial port; //creates object "port" of serial class
Robot robby; //creates object "robby" of robot class

//init the screen size variables here.
int screenW;
int screenH;

//Define a border on each side of the screen
int borderLeft  = 10;
int borderRight = 10;
int borderTop   = 50;
int borderBot   = 100;

//Size of top left box
boolean tlActiv = true;
int topLeftW    = 400;
int topLeftH    = 350;

//Size of top right box
boolean trActiv = true;
int topRightW    = 400;
int topRightH    = 350;

//Size of top center box
boolean tcActiv = false;
int topCenterW  = 1000;
int topCenterH  = 250;

//Size of bottom left box
boolean blActiv = true;
int botLeftW    = 400;
int botLeftH    = 350;

//Size of bottom right box
boolean brActiv = true;
int botRightW    = 400;
int botRightH    = 350;

//Size of bottom center box
boolean bcActiv = false;
int botCenterW  = 1000;
int botCenterH  = 250;

//Color adjustments, use this to adjust the color values to match your LEDs
int maxRed      = 255;
int maxGreen    = 255;
int maxBlue     = 255;

//How many pixels to skip while reading
int pixelSpread = 2;

String portName = "/dev/tty.usbmodem1411";
int portSpeed = 115200;

void setup() {
  // Get the screen width and height from Processing
  screenW = displayWidth;
  screenH = displayHeight;
  size(screenW/5, screenH/5, P2D);
  port = new Serial(this, portName, portSpeed); //set baud rate
  if( port.output == null ) {
        println("ERROR: Could not open serial port: "+portName);
        exit();
  }

  try //standard Robot class error check
  {
    robby = new Robot();
  }
  catch (AWTException e)
  {
    println("Robot class not supported by your system!");
    exit();
  }
}

void draw()
{
  long start = millis();
  fill(255);
  ellipse((screenW/5)/2, screenH/5/2, 80, 40);
  //rect((screenW/5)/2-50, screenH/5/2-25, 100, 50);

  int pixel; //ARGB variable with 32 int bytes where
  //sets of 8 bytes are: Alpha, Red, Green, Blue
  float r=0;
  float g=0;
  float b=0;

  //get screenshot into object "screenshot" of class BufferedImage
  BufferedImage screenshot = robby.createScreenCapture(new Rectangle(new Dimension(screenW,screenH)));


  //Calculate top left rectangle
  if (tlActiv)
  {
    for(int i = borderLeft; i < (topLeftW + borderLeft); i += pixelSpread)
    {
      for(int j = borderTop; j < (topLeftH + borderTop); j += pixelSpread)
      {
        pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
        r = r+(int)(maxRed&(pixel>>16)); //add up reds
        g = g+(int)(maxGreen&(pixel>>8)); //add up greens
        b = b+(int)(maxBlue&(pixel)); //add up blues
      }
    }
    r = r / ( (topLeftW / pixelSpread) * (topLeftH / pixelSpread) ); //average red
    g = g / ( (topLeftW / pixelSpread) * (topLeftH / pixelSpread) ); //average green
    b = b / ( (topLeftW / pixelSpread) * (topLeftH / pixelSpread) ); //average blue

    port.write(0xC1); //sync
    port.write((byte)(r)); //red
    port.write((byte)(g)); //green
    port.write((byte)(b)); //blue

    color topL = color(r, g, b);
    fill(topL);
    rect(borderLeft/5, borderTop/5, topLeftW/5, topLeftH/5);

    r = 0;
    g = 0;
    b = 0;
  }

  //Calculate top right rectangle
  if (trActiv)
  {
    for(int i = screenW - (borderRight + topRightW); i < (screenW-borderRight); i += pixelSpread)
    {
      for(int j = borderTop; j < (topRightH + borderBot); j += pixelSpread)
      {
        pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
        r = r+(int)(maxRed&(pixel>>16)); //add up reds
        g = g+(int)(maxGreen&(pixel>>8)); //add up greens
        b = b+(int)(maxBlue&(pixel)); //add up blues
      }
    }
    r = r / ( (topRightW / pixelSpread) * (topRightH / pixelSpread) ); //average red
    g = g / ( (topRightW / pixelSpread) * (topRightH / pixelSpread) ); //average green
    b = b / ( (topRightW / pixelSpread) * (topRightH / pixelSpread) ); //average blue

    port.write(0xC2); //sync
    port.write((byte)(r)); //red
    port.write((byte)(g)); //green
    port.write((byte)(b)); // blue

    color topR = color(r, g, b);
    fill(topR);
    rect(screenW/5 - ((topRightW/5)+(borderRight/5)), borderTop/5, topRightW/5, topRightH/5);

    r = 0;
    g = 0;
    b = 0;
  }


  //Calculate top center rectangle
  if (tcActiv)
  {
    for(int i = (screenW/2) - (topCenterW/2); i < (screenW/2) + (topCenterW/2); i += pixelSpread)
    {
      for(int j = borderTop; j < (topCenterH + borderTop); j += pixelSpread)
      {
        pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
        r = r+(int)(maxRed&(pixel>>16)); //add up reds
        g = g+(int)(maxGreen&(pixel>>8)); //add up greens
        b = b+(int)(maxBlue&(pixel)); //add up blues
      }
    }
    r = r / ( (topCenterW / pixelSpread) * (topCenterH / pixelSpread) ); //average red
    g = g / ( (topCenterW / pixelSpread) * (topCenterH / pixelSpread) ); //average green
    b = b / ( (topCenterW / pixelSpread) * (topCenterH / pixelSpread) ); //average blue

    port.write(0xC5); //sync
    port.write((byte)(r)); //red
    port.write((byte)(g)); //green
    port.write((byte)(b)); // blue

    color topR = color(r, g, b);
    fill(topR);
    rect((screenW/5)/2 - (topCenterW/5)/2, borderTop/5, topCenterW/5, topCenterH/5);

    r = 0;
    g = 0;
    b = 0;
  }


  //Calculate bottom left rectangle
  if (blActiv)
  {
    for(int i = borderLeft; i < (botLeftW + borderLeft); i += pixelSpread)
    {
      for(int j = screenH - (botLeftH + borderBot); j < (screenH - borderBot); j += pixelSpread)
      {
        pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
        r = r+(int)(maxRed&(pixel>>16)); //add up reds
        g = g+(int)(maxGreen&(pixel>>8)); //add up greens
        b = b+(int)(maxBlue&(pixel)); //add up blues
      }
    }
    r = r / ( (botLeftW / pixelSpread) * (botLeftH / pixelSpread) ); //average red
    g = g / ( (botLeftW / pixelSpread) * (botLeftH / pixelSpread) ); //average green
    b = b / ( (botLeftW / pixelSpread) * (botLeftH / pixelSpread) ); //average blue

    port.write(0xC3); //sync
    port.write((byte)(r)); //red
    port.write((byte)(g)); //green
    port.write((byte)(b)); //blue

    color botL = color(r, g, b);
    fill(botL);
    rect(borderLeft/5, screenH/5 - (botLeftH/5 + borderBot/5), botLeftW/5, botLeftH/5);

    r = 0;
    g = 0;
    b = 0;
  }

  //Calculate bottom right rectangle
  if (brActiv)
  {
    for(int i = screenW - (borderRight + botRightW); i < (screenW-borderRight); i += pixelSpread)
    {
      for(int j = screenH - (botRightH + borderBot); j < (screenH - borderBot); j += pixelSpread)
      {
        pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
        r = r+(int)(maxRed&(pixel>>16)); //add up reds
        g = g+(int)(maxGreen&(pixel>>8)); //add up greens
        b = b+(int)(maxBlue&(pixel)); //add up blues
      }
    }
    r = r / ( (botRightW / pixelSpread) * (botRightH / pixelSpread) ); //average red
    g = g / ( (botRightW / pixelSpread) * (botRightH / pixelSpread) ); //average green
    b = b / ( (botRightW / pixelSpread) * (botRightH / pixelSpread) ); //average blue

    port.write(0xC4); //sync
    port.write((byte)(r)); //red
    port.write((byte)(g)); //green
    port.write((byte)(b)); //blue

    color botR = color(r, g, b);
    fill(botR);
    rect(screenW/5 - ((topRightW/5)+(borderRight/5)), screenH/5 - (botLeftH/5 + borderBot/5), botRightW/5, botRightH/5);

    r = 0;
    g = 0;
    b = 0;
  }

  //Calculate bottom center rectangle
  if (bcActiv)
  {
    for(int i = (screenW/2) - (botCenterW/2); i < (screenW/2) + (botCenterW/2); i += pixelSpread)
    {
      for(int j = screenH - (botCenterH + borderBot); j < (screenH - borderBot); j += pixelSpread)
      {
        pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
        r = r+(int)(maxRed&(pixel>>16)); //add up reds
        g = g+(int)(maxGreen&(pixel>>8)); //add up greens
        b = b+(int)(maxBlue&(pixel)); //add up blues
      }
    }
    r = r / ( (botCenterW / pixelSpread) * (botCenterH / pixelSpread) ); //average red
    g = g / ( (botCenterW / pixelSpread) * (botCenterH / pixelSpread) ); //average green
    b = b / ( (botCenterW / pixelSpread) * (botCenterH / pixelSpread) ); //average blue

    port.write(0xC6); //sync
    port.write((byte)(r)); //red
    port.write((byte)(g)); //green
    port.write((byte)(b)); // blue

    color topR = color(r, g, b);
    fill(topR);
    rect((screenW/5)/2 - (botCenterW/5)/2, screenH/5 - (botCenterH/5 + borderBot/5), botCenterW/5, botCenterH/5);

    r = 0;
    g = 0;
    b = 0;
  }

  fill(0);
  textAlign(CENTER, CENTER);
  text(round(1000/(millis() - start)) + " fps", (screenW/5)/2, screenH/5/2);
}

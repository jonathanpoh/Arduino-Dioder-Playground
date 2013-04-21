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

//IMPORTANT!!!
//Put the right screen size in here, if isn't 100% right, the code might give some unexpected results.
int screenW     = 1920;
int screenH     = 1200;

//Define a border on each side of the screen
int borderLeft  = 10;
int borderRight = 10;
int borderTop   = 20;
int borderBot   = 20;

//Size of top left box
int topLeftW    = 350;
int topLeftH    = 450;

//Size of top right box
int topRightW   = 350;
int topRightH   = 450;

//Size of bottom left box
int botLeftW    = 350;
int botLeftH    = 450;

//Size of bottom right box
int botRightW   = 350;
int botRightH   = 450;

//Color adjustments, use this to adjust the color values to match your LEDs
int maxRed      = 255;
int maxGreen    = 255;
int maxBlue     = 125;

//How many pixels to skip while reading
int pixelSpread = 2;

void setup()
{
  port = new Serial(this, Serial.list()[0],115200); //set baud rate
  size(screenW/5, screenH/5); //window size

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
  int pixel; //ARGB variable with 32 int bytes where
  //sets of 8 bytes are: Alpha, Red, Green, Blue
  float r=0;
  float g=0;
  float b=0;

  int checksum = 0;

  //get screenshot into object "screenshot" of class BufferedImage
  BufferedImage screenshot = robby.createScreenCapture(new Rectangle(new Dimension(screenW,screenH)));

  //Calculate top left rectangle
  for(int i = borderLeft; i < (topLeftW + borderLeft); i += pixelSpread)
  {
    for(int j = borderTop; j < (topLeftH + borderTop); j += pixelSpread)     {       pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)       r = r+(int)(maxRed&(pixel>>16)); //add up reds
      g = g+(int)(maxGreen&(pixel>>8)); //add up greens
      b = b+(int)(maxBlue&(pixel)); //add up blues
    }
  }
  r = r / ( (topLeftW / pixelSpread) * (topLeftH / pixelSpread) ); //average red
  g = g / ( (topLeftW / pixelSpread) * (topLeftH / pixelSpread) ); //average green
  b = b / ( (topLeftW / pixelSpread) * (topLeftH / pixelSpread) ); //average blue

  checksum = checksum ^ int(r);
  checksum = checksum ^ int(g);
  checksum = checksum ^ int(b);

  port.write(0xAA); //sync
  port.write(0x00); //sync
  port.write((byte)(r)); //red
  port.write((byte)(g)); //green
  port.write((byte)(b)); //blue
  port.write((byte)(checksum));

  color topL = color(r, g, b);
  fill(topL);
  rect(borderLeft/5, borderTop/5, topLeftW/5, topLeftH/5);


  checksum = 0;

  //Calculate top right rectangle
  for(int i = screenW - (borderRight + topRightW); i < (screenW-borderRight); i += pixelSpread)
  {
    for(int j = borderTop; j < (topRightH + borderBot); j += pixelSpread)     {       pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)       r = r+(int)(maxRed&(pixel>>16)); //add up reds
      g = g+(int)(maxGreen&(pixel>>8)); //add up greens
      b = b+(int)(maxBlue&(pixel)); //add up blues
    }
  }
  r = r / ( (topRightW / pixelSpread) * (topRightH / pixelSpread) ); //average red
  g = g / ( (topRightW / pixelSpread) * (topRightH / pixelSpread) ); //average green
  b = b / ( (topRightW / pixelSpread) * (topRightH / pixelSpread) ); //average blue

  checksum = checksum ^ int(r);
  checksum = checksum ^ int(g);
  checksum = checksum ^ int(b);


  port.write(0xAA); //sync
  port.write(0x01); //channel number
  port.write((byte)(r)); //red
  port.write((byte)(g)); //green
  port.write((byte)(b)); // blue
  port.write((byte)(checksum)); //checksum byte


  color topR = color(r, g, b);
  fill(topR);
  rect(screenW/5 - ((topRightW/5)+(borderRight/5)), borderTop/5, topRightW/5, topRightH/5);

  checksum = 0;

  //Calculate bottom left rectangle
  for(int i = borderLeft; i < (botLeftW + borderLeft); i += pixelSpread)
  {
    for(int j = screenH - (botLeftH + borderBot); j < (screenH - borderBot); j += pixelSpread)     {       pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)       r = r+(int)(maxRed&(pixel>>16)); //add up reds
      g = g+(int)(maxGreen&(pixel>>8)); //add up greens
      b = b+(int)(maxBlue&(pixel)); //add up blues
    }
  }
  r = r / ( (botLeftW / pixelSpread) * (botLeftH / pixelSpread) ); //average red
  g = g / ( (botLeftW / pixelSpread) * (botLeftH / pixelSpread) ); //average green
  b = b / ( (botLeftW / pixelSpread) * (botLeftH / pixelSpread) ); //average blue

  checksum = checksum ^ int(r);
  checksum = checksum ^ int(g);
  checksum = checksum ^ int(b);


  port.write(0xAA); //sync
  port.write(0x02); //channel number
  port.write((byte)(r)); //red
  port.write((byte)(g)); //green
  port.write((byte)(b)); //blue
  port.write((byte)(checksum)); //checksum byte

  color botL = color(r, g, b);
  fill(botL);
  rect(borderLeft/5, screenH/5 - (botLeftH/5 + borderBot/5), botLeftW/5, botLeftH/5);


  checksum = 0;

  //Calculate bottom right rectangle
  for(int i = screenW - (borderRight + botRightW); i < (screenW-borderRight); i += pixelSpread)
  {
    for(int j = screenH - (botRightH + borderBot); j < (screenH - borderBot); j += pixelSpread)     {       pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)       r = r+(int)(maxRed&(pixel>>16)); //add up reds
      g = g+(int)(maxGreen&(pixel>>8)); //add up greens
      b = b+(int)(maxBlue&(pixel)); //add up blues
    }
  }
  r = r / ( (botRightW / pixelSpread) * (botRightH / pixelSpread) ); //average red
  g = g / ( (botRightW / pixelSpread) * (botRightH / pixelSpread) ); //average green
  b = b / ( (botRightW / pixelSpread) * (botRightH / pixelSpread) ); //average blue

  checksum = checksum ^ int(r);
  checksum = checksum ^ int(g);
  checksum = checksum ^ int(b);

  port.write(0xAA); //sync
  port.write(0x03); //channel number
  port.write((byte)(r)); //red
  port.write((byte)(g)); //green
  port.write((byte)(b)); //blue
  port.write((byte)(checksum)); //checksum byte

  color botR = color(r, g, b);
  fill(botR);
  rect(screenW/5 - ((topRightW/5)+(borderRight/5)), screenH/5 - (botLeftH/5 + borderBot/5), botRightW/5, botRightH/5);
}

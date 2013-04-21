// Developed by Rajarshi Roy
// http://siliconrepublic.blogspot.com.au/2011/02/arduino-based-pc-ambient-lighting.html
// Modifications by Jonathan Poh to support 2 channel output
import java.awt.Robot; //java library that lets us take screenshots
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.awt.DisplayMode;
import java.awt.Rectangle;
import java.awt.Dimension;
import processing.serial.*; //library for serial communication
import cc.arduino.*;

BufferedImage screenLeft;
BufferedImage screenRight;
String side;

Serial port; //creates object "port" of serial class
Robot robby; //creates object "robby" of robot class

void setup()
{
port = new Serial(this, Serial.list()[4],9600); //set baud rate
size(100, 100); //window size (doesn't matter)
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
int pixelLeft;
int pixelRight;
//ARGB variable with 32 int bytes where
//sets of 8 bytes are: Alpha, Red, Green, Blue
float r1=0;
float g1=0;
float b1=0;
float r2=0;
float g2=0;
float b2=0;


screenLeft = getScreen("left");
screenRight = getScreen("right");

int screenWidth = screenLeft.getWidth();
int screenHeight = screenLeft.getHeight();
int i=0;
int j=0;

//I skip every alternate pixel making my program 4 times faster
for(i =0;i<screenWidth; i=i+2){
for(j=0; j<screenHeight;j=j+2){
pixelLeft = screenLeft.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
pixelRight = screenRight.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
r1 = r1+(int)(255&(pixelLeft>>16)); //add up reds
g1 = g1+(int)(255&(pixelLeft>>8)); //add up greens
b1 = b1+(int)(255&(pixelLeft)); //add up blues

r2 = r2+(int)(255&(pixelRight>>16)); //add up reds
g2 = g2+(int)(255&(pixelRight>>8)); //add up greens
b2 = b2+(int)(255&(pixelRight)); //add up blues

}
}
r1=r1/((screenWidth / 2) * (screenHeight / 2)); //average red (remember that I skipped ever alternate pixel)
g1=g1/((screenWidth / 2) * (screenHeight / 2)); //average green
b1=b1/((screenWidth / 2) * (screenHeight / 2)); //average blue

r2=r2/((screenWidth / 2) * (screenHeight / 2)); //average red (remember that I skipped ever alternate pixel)
g2=g2/((screenWidth / 2) * (screenHeight / 2)); //average green
b2=b2/((screenWidth / 2) * (screenHeight / 2)); //average blue


port.write(0xff); //write marker (0xff) for synchronization
port.write((byte)(g1)); //write red value
port.write((byte)(b1)); //write green value
port.write((byte)(r1)); //write blue value
port.write((byte)(g2)); //write red value
port.write((byte)(b2)); //write green value
port.write((byte)(r2)); //write blue value
delay(10); //delay for safety

fill(r1,g1,b1);
noStroke();
rect(0,0, 50,100);

fill(r2,g2,b2);
noStroke();
rect(50,0, 50,100);
}

BufferedImage getScreen(String side) {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[] gs = ge.getScreenDevices();
  DisplayMode mode = gs[0].getDisplayMode();
  int halfScreenWidth = mode.getWidth() / 2;
  Rectangle bounds = new Rectangle();
  if (side.equals("left")) {
    bounds = new Rectangle(0, 0, halfScreenWidth, mode.getHeight());
  } else if (side.equals("right")) {
    bounds = new Rectangle(halfScreenWidth, 0, halfScreenWidth, mode.getHeight());
  }
  BufferedImage desktop = new BufferedImage(mode.getWidth(), mode.getHeight(), BufferedImage.TYPE_INT_RGB);

  try {
    desktop = new Robot(gs[0]).createScreenCapture(bounds);
  }
  catch(AWTException e) {
    System.err.println("Screen capture failed.");
  }

  return (desktop);
}

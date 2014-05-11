// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI
import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val, screen_increment, old_x=0, old_y=0;      // Data received from the serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed

void setup() 
{

  size(displayWidth-100, 600);//screen size setup, display width is read into teh program, and I
  //clipped it a little bit.  The screen height is set to be 600, which matches the scaled data,
  //the arduino will send over
  String portName = Serial.list()[2];//Set the Serial port COM or dev/tty.blah blah
  println(Serial.list());//look inthe console below to determine which number you put in
  
  myPort = new Serial(this, portName, 115200);//Set up the serial port
  myPort.bufferUntil(lf);//read in data until a line feed, so the arduino must do a println
  background(208,24,24);//make the background that cool blood red
}//setup

void draw(){
  //nothing in here, this is kind of like the void loop in arduino
}

void serialEvent(Serial myPort) { //this is called whenever data is sent over by the arduino

  inString = myPort.readString();//read in the new data, and store in inString
  inString = trim(inString);//get rid of any crap that isn't numbers, like the line feed
  val = int(inString);//convert the string into a number we can use
  strokeWeight(5);//beef up our white line
  stroke(255, 255, 255);//make the line white
  
  //here's where we draw the line on the screen
  //we need to draw the line from one point to the next
  //so we have the point we last drew, to the new point
  //values are written as an x,y system, where x is left to right, left most being 0
  //y is up and down, BUT 0 is the upmost point, 
  //so we subtract our value from the screen height to invert
  //screen increment, is how we progress teh line through the screen
  line(old_x, old_y, screen_increment, 600-val);
  
  //store the current x, y as the old x,y, so it is used next time
  old_x = screen_increment;
  old_y = 600-val;
  
  //increment the x coordinate,  you can play with this value to speed things up
  screen_increment=screen_increment+2;
  
  //this is needed to reset things when the line crashes into the end of the screen
  if(screen_increment>(displayWidth-100)){
    background(208,24,24); //refresh the screen, erases everything
    screen_increment=-50; //make the increment back to 0, 
    //but used 50, so it sweeps better into the screen
    //reset the old x,y values
  old_x = -50;
  old_y = 0;
  
  }// if screen...
}//serialEvent

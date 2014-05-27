// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI
import processing.serial.*;
import oscP5.*;
import netP5.*;


Serial myPort;  // Create object from Serial class
int screen_increment, old_x=0, old_y=0;      // Data received from the serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed

OscP5 oscP5;
NetAddress resolumeArenaAddress;

Beat lastBeat = new Beat(0, 0);
Beat roofBeat = new Beat(0, 0);
int sampleTime = 50;

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
  
  // start oscP5, listening for incoming messages at port 7001
  oscP5 = new OscP5(this,7001);
  
  //  myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
  //  an ip address and a port number. myRemoteLocation is used as parameter in
  //  oscP5.send() when sending osc packets to another computer, device, 
  //  application. usage see below. for testing purposes the listening port
  //  and the port of the remote location address are the same, hence you will
  //  send messages back to this sketch.
  resolumeArenaAddress = new NetAddress("127.0.0.1",7000);
}//setup

void manualEvent(){
  float val = (sin(millis()*0.005) * height * random(1));
  processValue((int)val);
  
}

void draw(){
//  manualEvent();   
}

void serialEvent(Serial myPort) { //this is called whenever data is sent over by the arduino
  inString = myPort.readString();//read in the new data, and store in inString
  inString = trim(inString);//get rid of any crap that isn't numbers, like the line feed
  int value = (int)map(int(inString), 0, 600, 0, height);
  processValue(value);
}

void processValue(int val){
  drawGraph(val);
  detectBeat(val);
}

void drawGraph(int val){
  strokeWeight(5);//beef up our white line
  stroke(255, 255, 255);//make the line white
  
  //here's where we draw the line on the screen
  //we need to draw the line from one point to the next
  //so we have the point we last drew, to the new point
  //values are written as an x,y system, where x is left to right, left most being 0
  //y is up and down, BUT 0 is the upmost point, 
  //so we subtract our value from the screen height to invert
  //screen increment, is how we progress teh line through the screen
  line(old_x, old_y, screen_increment, height-val);
  
  //store the current x, y as the old x,y, so it is used next time
  old_x = screen_increment;
  old_y = height-val;
  
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
  
  
//  //  /activeclip/video/opacity/values
//  OscMessage msg = new OscMessage("/layer2/clip1/video/opacity/values");
//  msg.add(map(val, 0, height, 0.0, 1.0)); /* add an int to the osc message */
//  // send the message
//  oscP5.send(msg, resolumeArenaAddress);

}//processValue


void detectBeat(int val){
  // "roofBeat" is used to keep track of the graphs recent max values
  if(val > roofBeat.value){
    roofBeat.init(millis(), val);
  } else if(millis() > roofBeat.time + sampleTime && roofBeat.time > lastBeat.time + sampleTime) {
    beat(roofBeat.value);
  } else{
    roofBeat.value -= 5;
  }

}

void beat(int val){
  lastBeat.init(millis(), val);
  println("beat at: " + lastBeat.time);
}  


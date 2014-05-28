// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI
import processing.serial.*;
import oscP5.*;
import netP5.*;


Serial myPort;  // Create object from Serial class
int screen_increment, old_x=0, old_y=0;      // Data received from the serial port
String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed

PGraphics canvas;
OscP5 oscP5;
Timer resolumeTimer;

Beat lastBeat = new Beat(0, 0);
Beat roofBeat = new Beat(0, 0);
Beat bottomBeat = new Beat(0,0);
int sampleTime = 30;
int minBeatTime = 100;
int minDynamic = 100;

Resolumer resolumer;

void setup() 
{
  size(displayWidth-300, 200);//screen size setup, display width is read into teh program, and I
  canvas = createGraphics(width, height);

  //clipped it a little bit.  The screen height is set to be 600, which matches the scaled data,
  //the arduino will send over
  String portName = Serial.list()[2];//Set the Serial port COM or dev/tty.blah blah
  println(Serial.list());//look inthe console below to determine which number you put in
  
  myPort = new Serial(this, portName, 115200);//Set up the serial port
  myPort.bufferUntil(lf);//read in data until a line feed, so the arduino must do a println
  background(208,24,24);//make the background that cool blood red
  
  // start oscP5, listening for incoming messages at port 7001
  oscP5 = new OscP5(this,7001);
  resolumer = new Resolumer(oscP5, "127.0.0.1", 7000);
  resolumeTimer = new Timer();
}//setup

void manualEvent(){
  float val = (sin(millis()*0.005) * height * random(1));
  processValue((int)val);
  
}

void draw(){
  manualEvent();
  resolumer.update();
  
  image(canvas, 0,0);
}

void serialEvent(Serial myPort) { //this is called whenever data is sent over by the arduino
  inString = myPort.readString();//read in the new data, and store in inString
  inString = trim(inString);//get rid of any crap that isn't numbers, like the line feed
  int value = (int)map(int(inString), 0, 600, 0, height);
//  processValue(value);
}

void processValue(int val){
  drawGraph(val);
  detectBeat(val);
}

void drawGraph(int val){
  canvas.beginDraw();
  canvas.strokeWeight(5);//beef up our white line
  canvas.stroke(255, 255, 255);//make the line white

  //here's where we draw the line on the screen
  //we need to draw the line from one point to the next
  //so we have the point we last drew, to the new point
  //values are written as an x,y system, where x is left to right, left most being 0
  //y is up and down, BUT 0 is the upmost point, 
  //so we subtract our value from the screen height to invert
  //screen increment, is how we progress teh line through the screen
  canvas.line(old_x, old_y, screen_increment, height-val);
  
  //store the current x, y as the old x,y, so it is used next time
  old_x = screen_increment;
  old_y = height-val;
  
  //increment the x coordinate,  you can play with this value to speed things up
  screen_increment=screen_increment+2;
  
  //this is needed to reset things when the line crashes into the end of the screen
  if(screen_increment>(width)){
    canvas.background(208,24,24); //refresh the screen, erases everything
    screen_increment=-50; //make the increment back to 0, 
    //but used 50, so it sweeps better into the screen
    //reset the old x,y values
    old_x = -50;
    old_y = 0;
    
  }// if screen...
  canvas.endDraw();
}//processValue


void detectBeat(int val){
//  // "roofBeat" is used to keep track of the graphs recent max values
//  if(val > roofBeat.value){
//    roofBeat.init(millis(), val);
//  } else if(millis() > roofBeat.time + sampleTime)
//      && roofBeat.time > lastBeat.time + minBeatTime) {
//    beat(roofBeat.value);
//  } else{
//    roofBeat.value -= 5;
//  }

  // bottomBeat is used to keep track of the graphcs recent min value...
  if(val < (int)(bottomBeat.value + bottomBeat.timeSince()*0.05) ){
    // drop the bottom
    bottomBeat.value = val;
    bottomBeat.time = millis();
  }

  // "roofBeat" is used to keep track of the graphs recent max values
  if(val > (int)(roofBeat.value - roofBeat.timeSince()*0.05) ){
    // raise the roof
    roofBeat.value = val;
    int curTime = millis();
    
    // beatconsider it a valid beat if we raised the roof,
      // and minBeatTime has passed since last beat
    if(curTime > lastBeat.time + minBeatTime &&
        // and a bottomBeat has been registered since last roofBeat
        bottomBeat.time > roofBeat.time &&
        // and there was at least 'minDynamic' difference between the bottomBeat and the roofBeat
        bottomBeat.value + minDynamic < roofBeat.value){
      beat(val);
    }

    roofBeat.time = curTime;
  }
}


void beat(int val){
  int curTime = millis();
//  println("beat (ms): " + (curTime - lastBeat.time));
  lastBeat.init(curTime, val);
  
  canvas.beginDraw();
  canvas.strokeWeight(1);//beef up our white line
  canvas.stroke(0);//make the line white
  canvas.line(screen_increment, 0, screen_increment, height);
  canvas.endDraw();

  resolumer.beatSound();
  resolumer.shake();
  println("timer f:" + resolumeTimer.fase);
  if(resolumeTimer.fase == 3){
    resolumer.f3(resolumeTimer.t);
  }
//  resolumer.fishEye();
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
//  print("### received an osc message.");
//  print(" addrpattern: "+theOscMessage.addrPattern());
//  println(" typetag: "+theOscMessage.typetag());
//  println(" arg 1: " + theOscMessage.get(0).floatValue());
//  

  if(theOscMessage.checkAddrPattern("/layer2/audio/position/values")){
    float t = theOscMessage.get(0).floatValue();
    resolumeTimer.setTime(t);
//    println("Videopos: "+t);
//    println("fase time: " + resolumeTimer.setTime(t));
//    println("fase time: " + resolumeTimer.faseTime());
  }
}


// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI
import processing.serial.*;

int serialDeviceIndex = 2;

Serial myPort;  // Create object from Serial class
int lf = 10;      // ASCII linefeed

int sampleTime = 30;
int minBeatTime = 100;
int minDynamic = 100;


// benchmarking values
int lastValue;
long receivedCount = 0;
long missedCount = 0;
int startMillis = 0;

// these could be defined locally in the serialEvent function,
// but since we're expecting this function to be called constantly,
// let's make it more efficient and just initialize them once and keep them in memory
int newValue, t, duration;
String inString;  // Input string from serial port

void setup() 
{
  size(100,100);//screen size setup, display width is read into teh program, and I

  String portName = Serial.list()[serialDeviceIndex];//Set the Serial port COM or dev/tty.blah blah
  println(Serial.list());//look inthe console below to determine which number you put in

  myPort = new Serial(this, portName, 9600);//Set up the serial port
  myPort.bufferUntil(lf);//read in data until a line feed, so the arduino must do a println
}//setup

void draw(){
  // image(canvas, 0,0);
}

void serialEvent(Serial myPort) { //this is called whenever data is sent over by the arduino
  t = millis();
  inString = myPort.readString();//read in the new data, and store in inString
  inString = trim(inString);//get rid of any crap that isn't numbers, like the line feed
  //println("Received: "+inString);
  
  newValue = int(inString); // convert from string to integer

  if(receivedCount > 0){ // only process value when we have previous data
    if(newValue < lastValue){
      missedCount += (newValue + 256) - lastValue - 1;
    } else {
      missedCount += newValue - lastValue - 1;
    }
  } else {
    startMillis = millis();
  }

  lastValue = newValue; // for processing the next value
  receivedCount++;
  duration = t - startMillis;
  println(newValue,
          "Received:", receivedCount,
          "// Missed:", missedCount, "(", missedCount / receivedCount * 100, "% )",
          "// Timespan (ms):", duration,
          "// Loss (bytes/s):", missedCount / (duration+1) * 1000 ); // adding 1 to duration to avoid divide by zero
}



// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI
import processing.serial.*;

Serial myPort;  // Create object from Serial class
int serialPortIdx = 3;
int bautRate = 9600; // 115200

int totalRunningTime = 3 * 60 * 1000; // 5 minutes in ms
int graph_width=2000, graph_height=500;
int minBpm = 0, maxBpm = 200;
int dotSize = 5;

static int beatsToAverage = 5; // use timing of a sequence of three beats to calculate bpm
int[] beatTimes = new int[beatsToAverage];
int totalTimes = 0;

String inString;  // Input string from serial port
int lf = 10;      // ASCII linefeed

PGraphics canvas;


int startTime, currentTime;
boolean bRunning, bDone;
float lastBpm = 0;

void setup() 
{
  size(displayWidth-300, 200);//screen size setup, display width is read into teh program, and I
  canvas = createGraphics(graph_width, graph_height);
  canvas.beginDraw();
  background(0,0,0);
  canvas.endDraw();
  canvas.noStroke();
  color(255, 255, 255);
  
  for(int i=0; i<beatsToAverage; i++){
    beatTimes[i] = 0;
  }

  //clipped it a little bit.  The screen height is set to be 600, which matches the scaled data,
  //the arduino will send over
  String portName = Serial.list()[serialPortIdx];//Set the Serial port COM or dev/tty.blah blah
  println(Serial.list());//look inthe console below to determine which number you put in
  
  myPort = new Serial(this, portName, bautRate);//Set up the serial port
  myPort.bufferUntil(lf);//read in data until a line feed, so the arduino must do a println

  background(0,0,0);//make the background that cool blood red

  bRunning = false;
  bDone = false;
  startTime = millis();
  currentTime = 0;

}//setup

void draw(){
  currentTime = millis() - startTime;
  
  if(bRunning){
    drawBeat(currentTime, lastBpm);
    image(canvas, 0,0, width, height);
    
    if(currentTime > totalRunningTime){
      println("done, saving frame");
      saveFrame("line-######.png");
      bDone = true;
      bRunning = false;
    }
    
    return;
  }

  if(bDone){
    return;
  }

  if(currentTime > 1000){ 
    println("starting");
    bRunning = true;
    startTime = currentTime;
  }
  
}

void serialEvent(Serial myPort) { //this is called whenever data is sent over by the arduino
  if(!bRunning) return;

  inString = myPort.readString();//read in the new data, and store in inString
  inString = trim(inString);//get rid of white-spac
  if(match(inString, "^B") != null){ // beat
    // println("Serial beat at:", currentTime);
    beat();
    return;
  }

  println("Unknown serial data at time", currentTime, ":", inString); 
}

void beat(){
  int t = currentTime;

  for(int i=beatsToAverage-1; i>0; i--){
    beatTimes[i] = beatTimes[i-1];
  }
  
  beatTimes[0] = t;
  // println("since last: ", beatTimes[0] - beatTimes[1]);
  int totalTime = 0;
  for(int i=1; i<beatsToAverage; i++){
    totalTime = totalTime + beatTimes[i-1] - beatTimes[i];
  }
  
  float averageTime = (float)totalTime / (beatsToAverage-1); // now we have the average time in milliseconds between two beats
  // println("total t:", totalTime, "avg time:", averageTime);  

  if(averageTime > 0) lastBpm = 60.0 / (averageTime/1000); // avoid divide by zero

  println("bpm at", t, ":", lastBpm);
//  drawBeat(t, bpm);
}

void drawBeat(int t, float bpm){
  int x = (int)map(t, 0, totalRunningTime, 0, graph_width);
  int y = (int)map(bpm, minBpm, maxBpm, graph_height, 0);
  
  
  canvas.beginDraw();
  color(255,255,255);
  noStroke();
  // canvas.noStroke();
  // canvas.ellipseMode(CENTER);
  canvas.ellipse(x, y, dotSize, dotSize);
  canvas.endDraw();
}


int serialBautRate = 9600;
int beatPin = 2;

int minDelayMs = 200; // minimal number of ms between two beats
unsigned long lastBeatMs = 0;
unsigned long t;

void setup(){
  //start serial connection
  Serial.begin(serialBautRate);

  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }

  //configure pin2 as an input and enable the internal pull-up resistor
  pinMode(beatPin, INPUT_PULLUP);
}

void loop(){
    //read the pushbutton value into a variable
    int beatVal = digitalRead(beatPin);

    if (beatVal == LOW) { // no beat detected nothing to do
      return;
  }

  // get beat time
  t = millis();
  
  if((t - lastBeatMs) <= minDelayMs) return;
 
  lastBeatMs = t;
    Serial.println("B"); // beating
}


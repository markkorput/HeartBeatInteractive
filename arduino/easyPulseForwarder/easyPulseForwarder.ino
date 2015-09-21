// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI

int data;
int pulsePort=A0;

void setup(){
  Serial.begin(9600);//for the processing sketch

  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
}//setup

void loop(){
  data = analogRead(pulsePort);//now write the next analog value to data[0]

//  data = map(data, 0, 1023, 0, 600);
  Serial.println(data);//send over the current value to the processing sketch, but scale it to match the screen height

  delay(50);//delay in here is important, we need enough samples to catch an entire waveform, so at least 1 sec of samples should be tored in data[0], 
  //so 5ms x 200 = 1000, we're good
}//loop

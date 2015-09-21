// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI

void setup(){
  Serial.begin(115200);//for the processing sketch

  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
}//setup

void loop(){
  unsigned long t = millis();
  int val = (int)(sin(t * 0.002) * 200) + 300;
  Serial.println(val);
  delay(5);
}



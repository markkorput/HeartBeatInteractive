// Based on code from this tutorial; https://www.youtube.com/watch?v=2_c0yE9QHNI

int heart_high, heart_low;
int data[200], i, mapped;

void setup(){
  Serial.begin(115200);//for the processing sketch

  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
}//setup

void loop(){
  heart_high=0;//reset the high before we look for it,  everything is higher than 0
  heart_low = 1023;//reset the low before we look for it, everything is lower than 1023
    
  for(i=200; i>0; i--){//search for the low and high out of the last 200 samples
    data[i] = data[i-1];// move everything back one, this will leave data[0] empty, but we put the next read there after this
      
    if(data[i]>heart_high)//check to see if we have something higher than the current high
      heart_high=data[i];//if it is higher, write the new value in
    if(data[i]<heart_low)//same idea as the high check
      heart_low=data[i];
  }//for loop
    
  data[0] = analogRead(0);//now write the next analog value to data[0]
  
//  mapped = map(data[0], 0, 1023, 0, 600);
  Serial.println(data[0]);//send over the current value to the processing sketch, but scale it to match the screen height

  delay(5);//delay in here is important, we need enough samples to catch an entire waveform, so at least 1 sec of samples should be tored in data[0], 
  //so 5ms x 200 = 1000, we're good
}//loop



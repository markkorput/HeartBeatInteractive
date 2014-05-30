/*
This Processing application (Easy_Pulse_PPG_Analyzer_V1.0) is developed for analyzing PPG waveform detected by Easy Pulse (V1.1) sensor, and 
transferred to PC through Arduino or any other microcontroller platform using a serial interface. The application
displays the received PPG waveform on a graphical window, and also computes the instantaneous heart rate.

"Easy Pulse is designed for hobby and educational applications to illustrate the principle of photoplethysmography (PPG)
as a non-invasive optical technique for detecting cardio-vascular pulse wave from a fingertip. It uses an infrared light
source to illuminate the finger on one side, and a photodetector placed on the other side measures the small variations 
in the transmitted light intensity. The variations in the photodetector signal are related to changes in blood volume 
inside the tissue. The signal is filtered and amplified to obtain a nice and clean PPG waveform, which is synchronous with
the heart beat. For more details, visit http://embedded-lab.com/blog/?p=7336"

Name of application: Easy_Pulse_PPG_Analyzer_V1.0
Author: Rajendra Bhatt (http://embedded-lab.com)

This software is licensed under a Creative Commons Attribution-ShareAlike 3.0
*/

// Define signal parameters
int Sampling_Time = 5;
int Num_Samples = 600;
int Peak_Threshold_Factor = 80;
int Minimum_Range = 500;
int Minimum_Peak_Separation = 50;  // 50*5=250 ms
int Moving_Average_Num = 10;
int Index1, Index2, Index3, i, j, k, ZeroFlag;
float Pulse_Rate, Temp1, Peak1, Peak2, Peak3, PR1, PR2, ADC_Range;
float Amplification_Factor,Peak_Magnitude, Peak_Threshold, Minima, Range, temp, Sum_Points, Num_Points;
float[] ADC_Value = new float[Num_Samples];
int[] ADC_Index = new int[Num_Samples];

// Define display
float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;
int rowCount;
int columnCount;
int currentColumn = 0;
 int count = 0;
int yearMin, yearMax;
int[] years;

int xInterval = 10;
int yInterval = 200;

PFont plotFont; 

import processing.serial.*;
Serial myPort;        // The serial port

void setup() {
  size(720, 450);
  

  // Corners of the plotted time series
  plotX1 = 20; 
  plotX2 = width - 20;
  labelX = 120;
  plotY1 = 50;
  plotY2 = height - 150;
  labelY = height - 100;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);
  smooth();

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
}

void draw() {
  background(224);
  
  // Show the plot area as a white box  
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
  drawTitle();
  drawAxisLabels();
  drawSampleLabels();

  ReadSamples();
  RemoveDC();
  if(ADC_Range < 50) {
    ZeroFlag = 1;
    ZeroData();
  } else ZeroFlag=0;
  ScaleData();
  FilterData();
  ComputeHeartRate();
  // draw the data using a long curve
  noFill();
  stroke(32, 128, 192);
  // balance the weight of the lines with the closeness of the data points
  strokeWeight(2);
  drawDataCurve();
  DisplayHeartRate();
  DisplayParameters();
}
  
  
void drawTitle() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = "Easy Pulse PPG Analyzer V1.0";
  text(title, plotX1, plotY1 - 10);
}

void drawAxisLabels() {
  fill(0);
  textSize(16);
  textLeading(15);
  textAlign(CENTER);
  text("Samples ("+nfc(Sampling_Time, 0)+" ms)", (plotX1+plotX2)/2, labelY);
}

void drawSampleLabels() {
  fill(0);
  textSize(14);
  textAlign(CENTER);
  
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
  
  for (int row = 0; row <= Num_Samples; row++) {
    if (row % 100 == 0) {
      float x = map(row, 0, Num_Samples+1, plotX1, plotX2);
      text(row, x, plotY2 + textAscent() + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}


void ReadSamples(){
  count = 0;
  do{
    if(myPort.available() > 0){
      String inString = myPort.readStringUntil('\n');
      if (inString != null) {
        inString = trim(inString);
        float inByte = float(inString);
     //   float inByte = float(inString);
        ADC_Value[count] = inByte;
        ADC_Index[count] = count;
        count = count + 1;
      }
    }  
  } while (count < Num_Samples);  

}

void RemoveDC(){
  Find_Minima(0);
  Find_Peak(0);
  ADC_Range = Peak_Magnitude-Minima;
  println("Peak Magnitude2= "+ Peak_Magnitude + ", Minima = "+ Minima);
  println("Range of ADC_Samples= "+ Range);
  
  // Subtract DC (minima) 
  for (int i = 0; i < Num_Samples; i++){
     ADC_Value[i] = ADC_Value[i] - Minima;
  }    
  Minima = 0;  // New Minima is zero
}  

void ZeroData(){
  for (int i = 0; i < Num_Samples; i++){
     ADC_Value[i] = 0;
     
  }
}

void ScaleData(){
  // Find peak value
  Find_Peak(0);
  Range = Peak_Magnitude - Minima;
  // Sclae from 1 to 1023 
  for (int i = 0; i < Num_Samples; i++){
     ADC_Value[i] = 1 + ((ADC_Value[i]-Minima)*1022)/Range;
     
  }
  Find_Peak(0);
  Find_Minima(0);  
  println("Peak Magnitude1= "+ Peak_Magnitude + ", Minima = "+ Minima);
}
  
void FilterData(){
  Num_Points = 2*Moving_Average_Num+1;
  for (i = Moving_Average_Num; i < Num_Samples-Moving_Average_Num; i++){
    Sum_Points = 0;
    for(k =0; k < Num_Points; k++){   
      Sum_Points = Sum_Points + ADC_Value[i-Moving_Average_Num+k]; 
    }    
  ADC_Value[i] = Sum_Points/Num_Points; 
  } 
  Find_Peak(Moving_Average_Num);
  Find_Minima(Moving_Average_Num);  
  println("Peak Magnitude2= "+ Peak_Magnitude + ", Minima = "+ Minima);
}

void ComputeHeartRate(){

  // Detect Peak magnitude and minima
  Find_Peak(Moving_Average_Num);
  Find_Minima(Moving_Average_Num);
  println("Peak Magnitude3= "+ Peak_Magnitude + ", Minima = "+ Minima); 
  Range = Peak_Magnitude - Minima;
  Peak_Threshold = Peak_Magnitude*Peak_Threshold_Factor;
  Peak_Threshold = Peak_Threshold/100;
  // Now detect three successive peaks 
  Peak1 = 0;
  Peak2 = 0;
  Peak3 = 0;
  Index1 = 0;
  Index2 = 0;
  Index3 = 0;
  // Find first peak
  for (j = Moving_Average_Num; j < Num_Samples-Moving_Average_Num; j++){
      if(ADC_Value[j] >= ADC_Value[j-1] && ADC_Value[j] > ADC_Value[j+1] && 
         ADC_Value[j] > Peak_Threshold && Peak1 == 0){
           Peak1 = ADC_Value[j];
           Index1 = j; 
      }
      // Search for second peak which is at least 10 sample time far
      if(Peak1 > 0 && j > (Index1+Minimum_Peak_Separation) && Peak2 == 0){
         if(ADC_Value[j] >= ADC_Value[j-1] && ADC_Value[j] > ADC_Value[j+1] && 
         ADC_Value[j] > Peak_Threshold){
            Peak2 = ADC_Value[j];
            Index2 = j; 
         } 
      } // Peak1 > 0
      
      // Search for the third peak which is at least 10 sample time far
      if(Peak2 > 0 && j > (Index2+Minimum_Peak_Separation) && Peak3 == 0){
         if(ADC_Value[j] >= ADC_Value[j-1] && ADC_Value[j] > ADC_Value[j+1] && 
         ADC_Value[j] > Peak_Threshold){
            Peak3 = ADC_Value[j];
            Index3 = j; 
         } 
      } // Peak2 > 0
    
  }  
 PR1 = (Index2-Index1)*Sampling_Time; // In milliseconds
 PR2 = (Index3-Index2)*Sampling_Time;
 println("PR1 = "+PR1+", PR2 = "+PR2);
 if(PR1 > 0 && abs(PR1-PR2) < 100){
    Pulse_Rate = (PR1+PR2)/2;
    Pulse_Rate = 60000/Pulse_Rate; // In BPM
    println("Index2= "+ Index2 + ", Index1 = "+ Index1+", PulseRate= "+Pulse_Rate); 
    println("Peak Magnitude= "+ Peak_Magnitude + ", Minima = "+ Minima); 
 }
}



void drawDataCurve() {
  beginShape();
  if(ZeroFlag == 0){
   for (int row = Moving_Average_Num; row < Num_Samples-Moving_Average_Num; row++) {
      stroke(32, 128, 192);
      float value = ADC_Value[row];
      float x = map(ADC_Index[row], 0, Num_Samples, plotX1, plotX2);
      float y = map(value, 0, Peak_Magnitude, plotY2, plotY1+15);
      if(row == Index1 || row == Index2 || row == Index3){
        textSize(20);
        text("x", x,y);
      }
      curveVertex(x, y);
      
      
     // if(row == Index2){
        //stroke(204, 102, 0);
      //  triangle(x,y-4, x-3, y+4, x+4, y+4 );
     // }
     // if(row == Index3){
        //stroke(204, 102, 0);
      //  triangle(x,y-4, x-3, y+4, x+4, y+4 );
      //}
   }
  }
  else{
    for (int row = Moving_Average_Num; row < Num_Samples-Moving_Average_Num; row++) {
    
      float value = ADC_Value[row];
      float x = map(ADC_Index[row], 0, Num_Samples, plotX1, plotX2);
      float y = 200;
      
      curveVertex(x, y);
      
   }
    
  }
  endShape();
}

void DisplayHeartRate(){
  fill(200,0,0);
  textSize(20);
  textAlign(LEFT);
  text("BPM", plotX2-40, plotY1 - 10);
  if(ZeroFlag == 0){
    text(nfc(Pulse_Rate, 1), plotX2-100, plotY1 - 10);
  }else {
    text("000", plotX2-100, plotY1 - 10);
  }
}


void Find_Minima(int Num){
  Minima = 1024;
  for (int m = Num; m < Num_Samples-Num; m++){
      if(Minima > ADC_Value[m]){
        Minima = ADC_Value[m];
      }
  }
}

void Find_Peak(int Num){
  Peak_Magnitude = 0;
  for (int m = Num; m < Num_Samples-Num; m++){
      if(Peak_Magnitude < ADC_Value[m]){
        Peak_Magnitude = ADC_Value[m];
     }
  }
}

void DisplayParameters(){
  fill(250,00,00);
  textSize(18);
  textAlign(LEFT);
  text("Range of ADC Samples = "+ ADC_Range, plotX1+5, plotY2+80);
}

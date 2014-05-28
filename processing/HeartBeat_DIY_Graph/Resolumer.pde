class Resolumer{
  OscP5 oscP5;
  String ip;
  int port;
  NetAddress netAddress;

  Resolumer(OscP5 _oscP5, String _ip, int _port ){
    oscP5 = _oscP5;
    ip = _ip;
    port = _port;
    netAddress = new NetAddress(ip, port);
  }

  void beatSound(){
    //    //  //  /activeclip/video/opacity/values
    //    OscMessage msg = new OscMessage("/layer1/clip1/connect");
    //    msg.add(1); /* add an int to the osc message */
    //    // send the message
    //    oscP5.send(msg, netAddress);
    
    OscMessage msg = new OscMessage("/layer1/clip1/audio/position/values");
    msg.add(0.0); /* add an int to the osc message */
    // send the message
    oscP5.send(msg, netAddress);
  }
  
  void oscSendFloat(String msgString, float value){
    OscMessage msg = new OscMessage(msgString);
    msg.add(value);
    oscP5.send(msg, netAddress);
  }

  void oscSendInt(String msgString, int value){
    OscMessage msg = new OscMessage(msgString);
    msg.add(value);
    oscP5.send(msg, netAddress);
  }

  void oscSendBool(String msgString, int value){
    oscSendInt(msgString, value);
  }

  void update(){
    updateShake();
    updateFishEye();
    updatef3();
  }
  
  int shakeAt = 0;

  
  void shake(){
    shakeAt = millis();
    // enable shaking effect
    oscSendBool("/layer2/clip1/video/effect1/bypassed", 0);
  }
  
  void updateShake(){
    if(shakeAt == 0 || millis() < shakeAt + 100) return;
    // disable shaking again
    oscSendBool("/layer2/clip1/video/effect1/bypassed", 1); 
    shakeAt = 0;
  }
  

  int fishEyeAt = 0;
  int fishEyeDuration = 0;
  float fishEyeIntensity = 0.6;
  
  void fishEye(){
    fishEyeAt = millis();
    fishEyeDuration = (int)random(100, 300);
    fishEyeIntensity = random(0.1, 0.5);

    // enable shaking effect
    oscSendFloat("/activeclip/video/effect2/param1/values", 0.0);
    oscSendBool("/layer2/clip1/video/effect2/bypassed", 0);
   
//    /activeclip/video/effect2/param1/values
  }
  
  void updateFishEye(){
    if(fishEyeAt == 0) return;
    int t = millis();

    if(t > fishEyeAt + fishEyeDuration){
      oscSendBool("/layer2/clip1/video/effect2/bypassed", 1);
      fishEyeAt = 0;
    }

    if(t <= fishEyeAt + fishEyeDuration * 0.5){
      oscSendFloat("/activeclip/video/effect2/param1/values", map(t, fishEyeAt, fishEyeAt+fishEyeDuration*0.5, 0.0, fishEyeIntensity));
      return;
    }
    
    oscSendFloat("/activeclip/video/effect2/param1/values", map(t, fishEyeAt+fishEyeDuration*0.5, fishEyeAt+fishEyeDuration, fishEyeIntensity, 0.0));
  }



  int f3At = 0;
  int f3Duration = 0;
  
  void f3(float t){
    f3At = millis();
    f3Duration = (int)random(500, 2000);
    // enable effect
    oscSendFloat("/layer3/clip1/audio/position/values", t);
    oscSendInt("/layer3/clip1/audio/position/direction", 1);
//    oscSendFloat("/layer3/clip1/audio/volume/values", 1.0);
println("f3");
  }
  
  void updatef3(){
    if(f3At == 0 || millis() < f3At + f3Duration) return;
    // disable shaking again
//    oscSendFloat("/layer3/clip1/audio/volume/values", 1.0);
    oscSendInt("/layer3/clip1/audio/position/direction", 2);
    f3At = 0;
  }
}

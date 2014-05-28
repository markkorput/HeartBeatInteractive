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

  void oscSendBool(String msgString, int value){
    OscMessage msg = new OscMessage(msgString);
    msg.add(value);
    oscP5.send(msg, netAddress);
  }

  void update(){
    updateShake();
    updateFishEye();
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
}

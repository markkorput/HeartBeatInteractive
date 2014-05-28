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
  
  int shakeAt = 0;

  
  void shake(){
    shakeAt = millis();
    // enable shaking effect
    OscMessage msg = new OscMessage("/layer2/clip1/video/effect1/bypassed");
    msg.add(0);
    oscP5.send(msg, netAddress);
  }
  
  void updateShake(){
    if(shakeAt == 0 || millis() < shakeAt + 100) return;
    // disable shaking again
    OscMessage msg = new OscMessage("/layer2/clip1/video/effect1/bypassed");
    msg.add(1);
    oscP5.send(msg, netAddress);
    
    shakeAt = 0;
  }
  
  void update(){
    updateShake();
  }
}

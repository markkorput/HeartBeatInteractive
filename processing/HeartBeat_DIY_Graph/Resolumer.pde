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
    //  //  /activeclip/video/opacity/values
    OscMessage msg = new OscMessage("/layer1/clip1/audio/position/values");
    msg.add(0.0); /* add an int to the osc message */
    // send the message
    oscP5.send(msg, netAddress);
  }
}

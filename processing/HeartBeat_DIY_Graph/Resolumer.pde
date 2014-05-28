class Resolumer{
  OscP5 oscP5;
  String ip;
  int port;
  NetAddress netAddress;
  Timer timer;

  Resolumer(OscP5 _oscP5, String _ip, int _port, Timer _timer){
    oscP5 = _oscP5;
    ip = _ip;
    port = _port;
    netAddress = new NetAddress(ip, port);
    timer = _timer;
  }

  void beat(){
    beatSound(cos(timer.faseTime()*TWO_PI)-0.1);
    if(random(1.0) > 0.4) shake(map(timer.faseTime(), 0.0, 1.0, 0.0, 0.03));
//    fishEye();
  
    if(timer.fase == 1){
      if(timer.faseTime() < 0.8 && timer.faseTime() > 0.2 && random(2.0) > 1.0) enableEffect(4, (int)random(100, 800));
    }

    if(timer.fase == 2){
      if(timer.faseTime() < 0.8 && timer.faseTime() > 0.2 && random(3.0) > 2.0) enableEffect(5, (int)random(100, 800));
    }


    if(timer.fase == 3){
      f3();
      if(random(5.0+cos(timer.faseTime()*TWO_PI-PI) * 5.0) > 4.0) scaleUp(random(0.3, 0.7), (int)random(60, 400));
    }
    
    if(timer.fase == 4){
      if(timer.faseTime() < 0.8 && random(5.0+timer.faseTime() * 5.0) > 4.0) enableEffect(3, (int)random(100, 1500));
    }
  }

  void beatSound(float volume){
    //    //  //  /activeclip/video/opacity/values
    //    OscMessage msg = new OscMessage("/layer1/clip1/connect");
    //    msg.add(1); /* add an int to the osc message */
    //    // send the message
    //    oscP5.send(msg, netAddress);
    
    oscSendFloat("/layer1/clip1/audio/volume/values", volume);
    oscSendFloat("/layer1/clip1/audio/position/values", 0.0);
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
    scaleUpUpdate();
    
    for(int i=0; i<effectAt.length; i++){
      updateEffect(i);
    }
  }
  
  int shakeAt = 0;
  
  void shake(float intensity){
    shakeAt = millis();
    oscSendFloat("/layer2/clip1/video/effect1/param2/values", intensity);
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
  
  void f3(){
    f3At = millis();
    f3Duration = (int)random(500, 2000);
    // enable effect
    oscSendFloat("/layer3/clip1/audio/position/values", resolumeTimer.t);
    oscSendInt("/layer3/clip1/audio/position/direction", 1);
  }
  
  void updatef3(){
    if(f3At == 0 || millis() < f3At + f3Duration) return;
    // disable shaking again
    oscSendInt("/layer3/clip1/audio/position/direction", 2);
    f3At = 0;
  }
  
  
  int[] effectAt = {0,0,0,0, 0, 0};
  int[] effectDuration = {0,0,0,0,0,0};

  void enableEffect(int effectNr, int duration){
    effectAt[effectNr] = millis();
    effectDuration[effectNr] = duration;
    // enable effect
    oscSendBool("/layer2/clip1/video/effect"+effectNr+"/bypassed", 0);
  }
  
  void updateEffect(int nr){
    if(effectAt[nr] == 0) return;
    int t = millis();

    if(t > effectAt[nr] + effectDuration[nr]){
      oscSendBool("/layer2/clip1/video/effect"+nr+"/bypassed", 1);
      effectAt[nr] = 0;
    }
  }
  
  int scaleUpAt = 0;
  int scaleUpDuration = 0;

  void scaleUp(float amount, int duration){
    scaleUpAt = millis();
    scaleUpDuration = duration;
    // enable effect
    oscSendFloat("/layer2/clip1/video/scale/values", amount);
  }
  
  void scaleUpUpdate(){
    if(scaleUpAt == 0) return;
    int t = millis();

    if(t > scaleUpAt + scaleUpDuration){
      oscSendFloat("/layer2/clip1/video/scale/values", 0.1);
      scaleUpAt = 0;
    }
  }
}

class Timer{
  float startFase1 = 0.0171;  
  float endFase1 =  0.256;
  float startFase2 = 0.270;
  float endFase2 =  0.55;
  float startFase3 = 0.55;
  float endFase3 =  0.765;
  float startFase4 = 0.777;
  float endFase4 =  0.997;
  
  float t = 0.0;
  int fase = 0;
  
  Timer(){
  }
  
  int setTime(float _t){
    t = _t;
    
    if(t >= startFase1 && t < endFase1) fase = 1;
    if(t >= startFase2 && t < endFase2) fase = 2;
    if(t >= startFase3 && t < endFase3) fase = 3;
    if(t >= startFase4 && t < endFase4) fase = 4;
    
    return fase;
  }
  
  float faseTime(){
    if(fase == 1) return map(t, startFase1, endFase1, 0.0, 1.0);
    if(fase == 2) return map(t, startFase2, endFase2, 0.0, 1.0);
    if(fase == 3) return map(t, startFase3, endFase3, 0.0, 1.0);
    if(fase == 4) return map(t, startFase4, endFase4, 0.0, 1.0);
    return 0.0;
  }
}


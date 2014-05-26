//
//  ClipTimer.cpp
//  BeatDirector
//
//  Created by Mark van de Korput on 26/05/14.
//
//

#include "ClipTimer.h"


ClipTimer::ClipTimer(){
    init();
}
    
ClipTimer::ClipTimer(unsigned int _layer, unsigned int _clip){
    init(_layer, _clip);
}

void ClipTimer::init(){
    timing1.pos = -1.0;
    timing2.pos = -1.0;
    
    extraTime = 2.0;
}

void ClipTimer::init(unsigned int _layer, unsigned int _clip){
    layer = _layer;
    clip = _clip;
    init();
}

std::string ClipTimer::id(){
    return "l" + ofToString(layer) + "c" + ofToString(clip);
}

void ClipTimer::registerPos(float pos){
    float curTime = ofGetElapsedTimef();
    // ofLogVerbose() << "REGISTER POS: " << ofToString(pos) <<  " AT TIME: " << ofToString(curTime);

    if(timing1.pos < 0){
        timing1.pos = pos;
        timing1.time = curTime;
    } else if(pos < timing2.pos){
        timing1.pos = pos;
        timing1.time = curTime;
        timing2.pos = -1.0;
    } else if((pos - timing1.pos) > 0.05){
        timing2.pos = pos;
        timing2.time = curTime;

        // we got two timing positions, allowing us to calculate
        // all the information about the specified clip that we need
        ofNotifyEvent(gotTimingEvent);
        // ofLogVerbose() << "GOT CLIP TIMING - total time: " << ofToString(totalClipTime());
    }
}

bool ClipTimer::gotTiming(){
    return timing2.pos > 0.0;
}

float ClipTimer::timingDistance(){
    return timing2.pos - timing1.pos;
}

float ClipTimer::timingTime(){
    return timing2.time - timing1.time;
}

float ClipTimer::totalClipTime(){
    if(!gotTiming()) return -1.0;
    
    return timingTime() / timingDistance();
}

float ClipTimer::extraTimeDistance(){
    if(!gotTiming()) return -1.0;

    // calculate the "distance" for the extraTime at the end
    return 1.0 / totalClipTime() * extraTime;
}

float ClipTimer::targetClipEndPosition(){
    if(!gotTiming()) return -1.0;

    // 1.0 is the end of the clip, substract the extraTime distance and you get the target position
    return 1.0 - extraTimeDistance();
}

float ClipTimer::targetClipEndTime(){
    if(!gotTiming()) return -1.0;

    float distance = targetClipEndPosition() - timing1.pos;
    return timing1.time + timingTime() / timingDistance() * distance;
}
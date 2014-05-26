//
//  ClipTimer.h
//  BeatDirector
//
//  Created by Mark van de Korput on 26/05/14.
//
//

#ifndef __BeatDirector__ClipTimer__
#define __BeatDirector__ClipTimer__

#include <iostream>
#include "ofMain.h"

struct ClipTiming {
    float pos, time;
};


class ClipTimer{
    public:
        unsigned int layer, clip;
    
        ClipTiming timing1, timing2;
        float extraTime;
        ofEvent<void> gotTimingEvent;
    
        ClipTimer();
        ClipTimer(unsigned int _layer, unsigned int _clip);

        void init();
        void init(unsigned int _layer, unsigned int _clip);
        std::string id();
        bool gotTiming();
        float timingDistance();
        float timingTime();
        void registerPos(float pos);
        float totalClipTime();
        float extraTimeDistance();
        float targetClipEndPosition();
        float targetClipEndTime();
};

#endif /* defined(__BeatDirector__ClipTimer__) */

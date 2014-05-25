#pragma once

#include "ofMain.h"
#include "ofxUI.h"
#include "ofEvents.h"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
		
    ofxUICanvas *gui;

    void exit();
    void guiEvent(ofxUIEventArgs &e);
    
    
    float lastBeat;
    
    int currentBPM();
    float currentTimeBetweenBeats();
    float nextBeatTime();
    float timeSinceLastBeat();
    
    ofEvent<void> beatEvent;
    void sendOscBeat();
};


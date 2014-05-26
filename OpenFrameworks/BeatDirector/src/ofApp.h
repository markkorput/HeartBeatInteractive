#pragma once

#include "ofMain.h"
#include "ofxUI.h"
#include "ofEvents.h"
#include "ofxOsc.h"

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
    ofxOscSender oscSender;
    ofxOscReceiver oscReceiver;

    void exit();
    void guiEvent(ofxUIEventArgs &e);
    void setupOscConnections();
    void setupOscOut();
    void setupOscIn();

    bool getOscInEnabled();
    bool getOscOutEnabled();
    string getOscInPort();
    string getOscOutPort();
    string getOscOutIP();

};

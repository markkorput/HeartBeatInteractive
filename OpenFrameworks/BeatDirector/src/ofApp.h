#pragma once

#include "ofMain.h"
#include "ofxUI.h"
#include "ofEvents.h"
#include "ofxOsc.h"


// we need to include the RegularExpression
// header file and say that we are using that
// name space
#include "Poco/RegularExpression.h"
//using Poco::RegularExpression;

#include "ClipTimer.h"

struct videoPosEventArgs {
    unsigned int layer, clip;
    float pos;
};

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
        void handleIncomingOsc();
        void onVideoPos(videoPosEventArgs & args);
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

        // variables
        ofxUICanvas *gui;
        ofxOscSender oscSender;
        ofxOscReceiver oscReceiver;
        vector<string *> oscInLog;
        ofEvent<videoPosEventArgs> videoPosEvent;
        ClipTimer clipTimer;

        void exit();
        void guiEvent(ofxUIEventArgs &e);
        void setupOscConnections();
        void setupOscOut();
        void setupOscIn();
        void onVideoTiming();
        void onClipChange();

        // UI helper methods
        bool getOscInEnabled();
        bool getOscOutEnabled();
        string getOscInPort();
        string getOscOutPort();
        string getOscOutIP();
};

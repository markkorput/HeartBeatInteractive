#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    gui = new ofxUICanvas();        //Creates a canvas at (0,0) using the default width
    
    gui->addNumberDialer("BPM", 1, 300, 120, 1);
//    gui->addSlider("BPM",1.0,300.0,120.0);
    gui->addToggle("BEATING", true);
    gui->addTextInput("MESSAGE", "heartbeat/beat");

    gui->addToggle("OSC_OUT_ENABLE", true);
    gui->addTextInput("OSCIP", "127.0.0.1");
    gui->addTextInput("OSCPORT", "12346");

    ofAddListener(gui->newGUIEvent, this, &ofApp::guiEvent);
    gui->autoSizeToFitWidgets();
    gui->loadSettings("settings.xml");

    ofAddListener(beatEvent, this, &ofApp::sendOscBeat);
    
    lastBeat = 0.0;
}

//--------------------------------------------------------------
void ofApp::update(){
    if(ofGetElapsedTimef() > nextBeatTime()){
        ofNotifyEvent(beatEvent);
        lastBeat = ofGetElapsedTimef();
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    float value = ofMap(timeSinceLastBeat(), 0, currentTimeBetweenBeats(), 120, 100);
    ofBackground(value, 100, 100);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}


//--------------------------------------------------------------
void ofApp::exit()
{
    gui->saveSettings("settings.xml");
    delete gui;
}

void ofApp::guiEvent(ofxUIEventArgs &e)
{
    if(e.getName() == "BACKGROUND")
    {
        ofxUISlider *slider = e.getSlider();
        ofBackground(slider->getScaledValue());
    }
}


//--------------------------------------------------------------
int ofApp::currentBPM(){
    ofxUINumberDialer *bpmInput = (ofxUINumberDialer*)gui->getWidget("BPM");
    return (int) bpmInput->getValue();
}

float ofApp::currentTimeBetweenBeats(){
    return 60.0 / currentBPM();
}

float ofApp::nextBeatTime(){
    return lastBeat + currentTimeBetweenBeats();
}

float ofApp::timeSinceLastBeat(){
    return ofGetElapsedTimef() - lastBeat;
}

//--------------------------------------------------------------
void ofApp::sendOscBeat(){
    ofxUITextInput *portInput = (ofxUITextInput*)gui->getWidget("OSCPORT");
    portInput->setTextString(portInput->getTextString() + ".");
}

                        
                        
                        

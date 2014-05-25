#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    gui = new ofxUICanvas();        //Creates a canvas at (0,0) using the default width
    
    gui->addNumberDialer("BPM", 1, 300, 120, 1);
//    gui->addSlider("BPM",1.0,300.0,120.0);
    gui->addToggle("BEATING", true);
    gui->addTextInput("MESSAGE", "/heartbeat/beat");

    gui->addToggle("OSC_OUT_ENABLE", true);
    gui->addTextInput("OSCIP", "127.0.0.1");
    gui->addTextInput("OSCPORT", "12346");

    ofAddListener(gui->newGUIEvent, this, &ofApp::guiEvent);
    gui->autoSizeToFitWidgets();
    gui->loadSettings("settings.xml");

    lastBeat = 0.0;
    
    setupOscSender();
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

    // if the user changed to osc port or osc host value, immediately re-initialize the oscSender to the new values
    if(e.getName() == "OSCPORT" || e.getName() == "OSCIP" || e.getName() == "OSC_OUT_ENABLE"){
        setupOscSender();
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

string ofApp::getOscPort(){
    return ((ofxUITextInput*)gui->getWidget("OSCPORT"))->getTextString();
}

string ofApp::getOscIP(){
    return ((ofxUITextInput*)gui->getWidget("OSCIP"))->getTextString();
}

string ofApp::getOscMessage(){
    return ((ofxUITextInput*)gui->getWidget("MESSAGE"))->getTextString();
}

bool ofApp::getOscEnabled(){
    return ((ofxUIToggle*)gui->getWidget("OSC_OUT_ENABLE"))->getValue();
}



//--------------------------------------------------------------
void ofApp::sendOscBeat(){
    ofxOscMessage msg;
	msg.setAddress(getOscMessage());
	oscSender.sendMessage(msg);
}

//--------------------------------------------------------------
void ofApp::setupOscSender(){
    oscSender.setup(getOscIP(), ofToInt(getOscPort()));

    if(getOscEnabled()){
        ofAddListener(beatEvent, this, &ofApp::sendOscBeat);
    } else {
        ofRemoveListener(beatEvent, this, &ofApp::sendOscBeat);
    }
}


                        

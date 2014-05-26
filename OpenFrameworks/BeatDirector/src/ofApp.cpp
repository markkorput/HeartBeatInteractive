#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    // Enable some logging information
	ofSetLogLevel(OF_LOG_VERBOSE);
    ofSetWindowShape(300, 600);

    //Creates a canvas at (0,0) using the default width
    gui = new ofxUICanvas();

    gui->addToggle("OSC_IN", true);
    gui->addTextInput("OSC_IN_PORT", "12346");

    gui->addToggle("OSC_OUT", true);
    gui->addTextInput("OSC_OUT_IP", "127.0.0.1");
    gui->addTextInput("OSC_OUT_PORT", "12347");

    gui->addTextArea("OSC_IN_LOG", "");
    
    ofAddListener(gui->newGUIEvent, this, &ofApp::guiEvent);
    gui->autoSizeToFitWidgets();
    gui->loadSettings("settings.xml");

    setupOscConnections();
}

//--------------------------------------------------------------
void ofApp::update(){
    if(getOscInEnabled()) handleIncomingOsc();
}

void ofApp::handleIncomingOsc(){
    while(oscReceiver.hasWaitingMessages()){
        // get the next message
		ofxOscMessage m;
		oscReceiver.getNextMessage(&m);

        string params = "";
        for(int i = 0; i < m.getNumArgs(); i++){
            if(i > 0) params += ", ";

            if(m.getArgTypeName(i) == "float")
                params += ofToString(m.getArgAsFloat(i));
            else
                params += m.getArgAsString(i);
        }

        ofLogVerbose() << "OSC IN - " << m.getAddress() << " (" << params << ")";
        

//		// check for mouse moved message
//		if(m.getAddress() == "/mouse/position"){
//			// both the arguments are int32's
//			mouseX = m.getArgAsInt32(0);
//			mouseY = m.getArgAsInt32(1);
//		}
//        ofxUITextArea *a;
    }
}

//--------------------------------------------------------------
void ofApp::draw(){

}

//--------------------------------------------------------------
void ofApp::exit()
{
    gui->saveSettings("settings.xml");
    delete gui;
}

void ofApp::guiEvent(ofxUIEventArgs &e)
{
    // if the user changed to osc port or osc host value, immediately re-initialize the oscSender to the new values
    if(e.getName() == "OSC_OUT" || e.getName() == "OSC_OUT_IP" || e.getName() == "OSC_OUT_PORT"){
        setupOscOut();
    }

    // if the user changed to osc port or osc host value, immediately re-initialize the oscSender to the new values
    if(e.getName() == "OSC_IN_PORT"){
        setupOscIn();
    }
}

void ofApp::setupOscConnections(){
    setupOscOut();
    setupOscIn();
}

void ofApp::setupOscOut(){
    ofLogNotice("> setupOscOut");

    try{
        oscSender.setup(getOscOutIP(), ofToInt(getOscOutPort()));
    } catch (exception & e) {
        ofLogError() << "Something went wrong while setting up oscSender";
    }
        
    if(getOscOutEnabled()){
//        ofAddListener(beatEvent, this, &ofApp::sendOscBeat);
    } else {
//        ofRemoveListener(beatEvent, this, &ofApp::sendOscBeat);
    }
}

void ofApp::setupOscIn(){
    ofLogNotice("> setupOscIn");

    try{
        oscReceiver.setup(ofToInt(getOscInPort()));
    } catch (exception & e) {
        ofLogError() << "Something went wrong while setting up oscReceiver";
    }
}

bool ofApp::getOscInEnabled(){ return ((ofxUIToggle*)gui->getWidget("OSC_IN"))->getValue(); }
bool ofApp::getOscOutEnabled(){ return ((ofxUIToggle*)gui->getWidget("OSC_OUT"))->getValue(); }
string ofApp::getOscInPort(){ return ((ofxUITextInput*)gui->getWidget("OSC_IN_PORT"))->getTextString(); }
string ofApp::getOscOutPort(){ return ((ofxUITextInput*)gui->getWidget("OSC_OUT_PORT"))->getTextString(); }
string ofApp::getOscOutIP(){ return ((ofxUITextInput*)gui->getWidget("OSC_OUT_IP"))->getTextString(); }

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


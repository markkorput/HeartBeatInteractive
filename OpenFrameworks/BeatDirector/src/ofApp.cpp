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

    gui->addLabel("CUR_CLIP", "Current clip");
    gui->addLabel("CUR_CLIP_ID", "unknown");
    gui->addLabel("CUR_TIME_LABEL", "Elapsed time");
    gui->addLabel("CUR_TIME", "unknown");
    gui->addLabel("CUR_CLIP_TOTAL_TIME_LABEL", "Total clip time");
    gui->addLabel("CUR_CLIP_TOTAL_TIME", "unknown");
    gui->addLabel("CUR_CLIP_TARGET_END_TIME_LABEL", "Target clip end time");
    gui->addLabel("CUR_CLIP_TARGET_END_TIME", "unknown");
    
    gui->addTextArea("OSC_IN_LOG", "");

    gui->autoSizeToFitWidgets();
    gui->loadSettings("settings.xml");

    setupOscConnections();

    ofAddListener(gui->newGUIEvent, this, &ofApp::guiEvent);
    ofAddListener(videoPosEvent, this, &ofApp::onVideoPos);
    ofAddListener(clipTimer.gotTimingEvent, this, &ofApp::onVideoTiming);
    ofAddListener(clipTimer.clipChangeEvent, this, &ofApp::onClipChange);
}

//--------------------------------------------------------------
void ofApp::update(){
    if(getOscInEnabled()) handleIncomingOsc();

    ((ofxUILabel*)gui->getWidget("CUR_TIME"))->setLabel(ofToString(ofGetElapsedTimef()));
}

void ofApp::handleIncomingOsc(){
    ofxOscMessage m;
    while(oscReceiver.getNextMessage(&m)){
//    while(oscReceiver.hasWaitingMessages()){
        // get the next message
            ofxOscMessage m;
            oscReceiver.getNextMessage(&m);

        // LOG all incoming osc messages
//            string params = "";
//            for(int i = 0; i < m.getNumArgs(); i++){
//                if(i > 0) params += ", ";
//
//                if(m.getArgTypeName(i) == "float")
//                    params += ofToString(m.getArgAsFloat(i));
//                else
//                    params += m.getArgAsString(i);
//            }
//
//            ofLogVerbose() << "OSC IN - " << m.getAddress() << " (" << params << ")";
 
        // deal with video position messages
            Poco::RegularExpression re1("^/layer([0-9]+)/clip([0-9]+)/video/position/values$");
            Poco::RegularExpression re2("^/layer([0-9]+)/clip([0-9]+)/audio/position/values$");
            std::vector<std::string> vec;

            if(re1.split(m.getAddress(), 0, vec) == 3 || re2.split(m.getAddress(), 0, vec) == 3){ // three matches? (the whole matching substring, the layer number match and the clip number match)
                // ofLogVerbose() << "VIDEO POS (layer: " << vec[1] << ", clip: " << vec[2] << ") = " << ofToString(m.getArgAsFloat(0));
                videoPosEventArgs args;
                args.layer = ofToInt(vec[1]);
                args.clip = ofToInt(vec[2]);
                args.pos = m.getArgAsFloat(0);
                ofNotifyEvent(videoPosEvent, args);
            }
    }
}

void ofApp::onVideoPos(videoPosEventArgs & args){
    // ofLogVerbose() << "VIDEO POS (layer: " << ofToString(args.layer) << ", clip: " << ofToString(args.clip) << ") = " << ofToString(args.pos);
    
    clipTimer.setClip(args.layer, args.clip);
    clipTimer.registerPos(args.pos);
}

void ofApp::onClipChange(){
    ((ofxUILabel*)gui->getWidget("CUR_CLIP_ID"))->setLabel(ofToString(clipTimer.id()));
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

void ofApp::onVideoTiming(){
    if(clipTimer.gotTiming()){
        ((ofxUILabel*)gui->getWidget("CUR_CLIP_TOTAL_TIME"))->setLabel(ofToString(clipTimer.totalClipTime()));
        ((ofxUILabel*)gui->getWidget("CUR_CLIP_TARGET_END_TIME"))->setLabel(ofToString(clipTimer.targetClipEndTime()));
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


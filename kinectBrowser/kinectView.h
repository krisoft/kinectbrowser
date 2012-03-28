//
//  myOView.h
//  proba
//
//  Created by Gergely Krisztian on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef kinectview_h
#define kinectview_h
#import <AppKit/AppKit.h>
#import "userTracking.h"
//#import "handTracking.h"
//#import "gestureTracking.h"


#define MAX_DEPTH 10000

@interface kinectView : NSOpenGLView
{
    float g_pDepthHist[MAX_DEPTH];
    XnRGB24Pixel* g_pTexMap;
    unsigned int g_nTexMapX;
    unsigned int g_nTexMapY;
    
    xn::Context g_context;
    xn::DepthGenerator g_depth;
    xn::ImageGenerator g_image;
    xn::DepthMetaData g_depthMD;
    xn::ImageMetaData g_imageMD;
    
//    HandTracker handtracker;
    UserTracker userTracker;
    //HandTracker handTracker;
    //GestureTracker gestureTracker;

    int activeUserId;
    int x,y,width,height,aR,bR,aG,bG,aB,bB,uR,uG,uB;
    BOOL left;
    BOOL top;
    NSRect oldRect;
    BOOL kinect_ready;
}
- (void) drawRect: (NSRect) bounds;
- (void) setupGenerators;
- (void) startKinect;
- (void) updateKinect;
- (void) repositionTo:(NSRect)rect;

@property (nonatomic, retain) IBOutlet WebView *web;
@end

#endif

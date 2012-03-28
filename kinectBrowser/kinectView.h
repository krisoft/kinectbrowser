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
#import "handTracking.h"
#import "AppDelegate.h"

#define GL_WIN_SIZE_X 300
#define GL_WIN_SIZE_Y 200

#define DISPLAY_MODE_OVERLAY	1
#define DISPLAY_MODE_DEPTH		2
#define DISPLAY_MODE_IMAGE		3
#define DEFAULT_DISPLAY_MODE	DISPLAY_MODE_DEPTH

#define MAX_DEPTH 10000

@interface kinectView : NSOpenGLView
{
    float g_pDepthHist[MAX_DEPTH];
    XnRGB24Pixel* g_pTexMap;
    unsigned int g_nTexMapX;
    unsigned int g_nTexMapY;
    
    unsigned int g_nViewState;
    
    xn::Context g_context;
    xn::ScriptNode g_scriptNode;
    xn::DepthGenerator g_depth;
    xn::ImageGenerator g_image;
    xn::DepthMetaData g_depthMD;
    xn::ImageMetaData g_imageMD;
    
    HandTracker handtracker;
    
    
    BOOL kinect_ready;
    
    AppDelegate *app;
}
- (void) drawRect: (NSRect) bounds;

-(void)handId:(int)nId Pont:(XnPoint3D) point;
-(void)handLostId:(int)nId;

@property (nonatomic, retain) IBOutlet AppDelegate *app;
@end

#endif

//
//  AppDelegate.h
//  tryJS
//
//  Created by Gergely Krisztian on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "kinectView.h"


@interface AppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>{
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet kinectView *kinect;
@property (nonatomic, retain) IBOutlet WebView *web;
@property (nonatomic, retain) IBOutlet NSTextField *url;
@property (nonatomic, retain) IBOutlet NSTextField *console;

- (void)refreshNow;
- (void)toogleUrlBar;
- (void)toogleConsole;

@end

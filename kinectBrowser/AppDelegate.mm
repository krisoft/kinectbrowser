//
//  AppDelegate.m
//  tryJS
//
//  Created by Gergely Krisztian on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize kinect = _kinect;
@synthesize web = _web;
@synthesize url = _url;
@synthesize console = _console;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self refreshNow];
    [_window setCollectionBehavior:
        NSWindowCollectionBehaviorFullScreenPrimary];
    [self windowDidResize:nil];
    [_web setFrameLoadDelegate:self];
    [_console setHidden:YES];

}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    NSLog(@"init console2");
    [windowScriptObject setValue:_kinect forKey:@"kinect"];
    [windowScriptObject setValue:self forKey:@"app"];
    [windowScriptObject setValue:self forKey:@"console"];
}

- (void)refreshNow{
    NSLog(@"refresh");
    [[NSURLCache sharedURLCache] setMemoryCapacity:0]; 
    [[NSURLCache sharedURLCache] setDiskCapacity:0]; 
    [[_web mainFrame] reloadFromOrigin];
    [[_web mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_url stringValue]]]];
}

- (void)toogleUrlBar{
    [_url setHidden:![_url isHidden]];
}

- (void)toogleConsole{
    [_console setHidden:![_console isHidden]];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [_url setStringValue:url];
    }
}

- (void)windowDidResize:(NSNotification *)notification{
    NSRect f = _web.frame;
    f.size = [_window frame].size;
    f.size.height -= _window.frame.size.height - [[_window contentView] frame].size.height;
    _web.frame = f;
    [_kinect repositionTo:_web.frame];
}

+(NSString*)webScriptNameForSelector:(SEL)sel
{
    if(sel == @selector(log:))
        return @"log";
    return nil;
}

//this allows JavaScript to call the -logJavaScriptString: method
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(log:))
        return NO;
    return YES;
}

- (void)log:(NSString*)what{
    NSLog(@"js:%@",what);
    //[_console setStringValue:[NSString stringWithFormat:@"%@\n%@",what,[_console stringValue]]];
}


@end

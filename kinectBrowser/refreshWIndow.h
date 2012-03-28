//
//  refreshWIndow.h
//  proba
//
//  Created by Gergely Krisztian on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "AppDelegate.h"

@interface refreshWIndow : NSWindow{
    AppDelegate *app;
}
- (void)keyDown:(NSEvent *)event;
@property (nonatomic, retain) IBOutlet AppDelegate *app;
@end

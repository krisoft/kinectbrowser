//
//  refreshWIndow.m
//  proba
//
//  Created by Gergely Krisztian on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "refreshWIndow.h"


@implementation refreshWIndow
@synthesize app;

- (void)keyDown:(NSEvent *)event{
    NSLog(@"keyCode: %i",[event keyCode]);
    if([event keyCode]==15 && [event modifierFlags]&NSCommandKeyMask){
        [app refreshNow];
    }
    if([event keyCode]==0){
        [app toogleUrlBar];
    }
    if([event keyCode]==8){
        [app toogleConsole];
    }
}


@end

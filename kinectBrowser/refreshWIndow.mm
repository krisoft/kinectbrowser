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
    if([event keyCode]==15 && [event modifierFlags]&NSCommandKeyMask){
        [app refreshNow];
    }
}


@end

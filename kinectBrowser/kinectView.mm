//
//  myOView.m
//  proba
//
//  Created by Gergely Krisztian on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <XnOS.h>
#include <XnCppWrapper.h>
using namespace xn;

#import "kinectView.h"
#import <OpenGL/gl.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSKeyValueCoding.h>

#define LENGTHOF(arr)			(sizeof(arr)/sizeof(arr[0]))

@implementation kinectView

@synthesize web = _web;

- (void)awakeFromNib {
    kinect_ready = NO;
    [self setHidden:YES];
    left = YES;
    top = NO;
    x = 100;
    y = 100;
    width = 300;
    height = 200;
    aR = 62;
    aG = 63;
    aB = 47;
    
    bR = 252;
    bG = 253;
    bB = 248;
    
    uR = 145;
    uG = 129;
    uB = 30;
    activeUserId = -1;
    [self startKinect];
}

- (void) repositionTo:(NSRect)rect{
    oldRect = rect;
    NSRect f;
    f.size.width = width;
    f.size.height = height;
    if(left){
        f.origin.x = x;
    }else{
        f.origin.x = rect.size.width-width-x;
    }
    if(!top){
        f.origin.y = y;
    }else{
        f.origin.y = rect.size.height-height-y;
    }
    self.frame = f;
}



+(NSString*)webScriptNameForSelector:(SEL)sel
{
    if(sel == @selector(enable))
        return @"enable";
    if(sel == @selector(disable))
        return @"disable";
    if(sel == @selector(trackHand:))
        return @"trackHand";
    if(sel == @selector(whereUser:))
        return @"whereUser";
    if(sel == @selector(activeUser:))
        return @"activeUser";
    if(sel == @selector(whoIsThere:))
        return @"whoIsThere";
    if(sel == @selector(positionOfUser: joint:))
        return @"positionOfJoint";
    if(sel == @selector(getUsers))
        return @"getUsers";
    if(sel == @selector(getTrackedUsers))
        return @"getTrackedUsers";
    if(sel == @selector(style:))
        return @"style";
    if(sel == @selector(log:))
        return @"log";
    return nil;
}

//this allows JavaScript to call the -logJavaScriptString: method
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(enable))
        return NO;
    if(sel == @selector(disable))
        return NO;
    if(sel == @selector(whereUser:))
        return NO;
    if(sel == @selector(activeUser:))
        return NO;
    if(sel == @selector(whoIsThere:))
        return NO;
    if(sel == @selector(positionOfUser: joint:))
        return NO;

    if(sel == @selector(getUsers))
        return NO;
    if(sel == @selector(getTrackedUsers))
        return NO;
    if(sel == @selector(trackHand:))
        return NO;
    if(sel == @selector(style:))
        return NO;
    if(sel == @selector(log:))
        return NO;
    return YES;
}
-(void)log:(NSString*)msg{
    NSLog(@"js:%@",msg);
}
-(void)enable{
    [self setHidden:NO];
}
-(void)disable{
    [self setHidden:YES];
}
-(NSArray *)getUsers{
    return userTracker.getUsers();
}
-(NSArray *)getTrackedUsers{
    return userTracker.getTrackedUsers();
}
-(NSArray *)whereUser:(NSNumber *) num{
    return userTracker.positionOfUser([num intValue]);
}
-(void)activeUser:(NSNumber *) num{
    activeUserId = [num intValue];
}

-(id)whoIsThere:(WebScriptObject *) object{
    if(![object isKindOfClass:[WebScriptObject class]])
        return [NSNumber numberWithFloat:-1];
    WebScriptObject *obj = (WebScriptObject*)object;
    XnPoint3D pos,projected;
    id xThing = [obj valueForKey:@"x"];
    if([xThing isKindOfClass:[NSNumber class]]){
        pos.X = [xThing floatValue];
    }
    id yThing = [obj valueForKey:@"y"];
    if([yThing isKindOfClass:[NSNumber class]]){
        pos.Y= [yThing floatValue];
    }
    id zThing = [obj valueForKey:@"z"];
    if([zThing isKindOfClass:[NSNumber class]]){
        pos.Z= [zThing floatValue];
    }
    g_depth.ConvertRealWorldToProjective(1, &pos, &projected);
    int user = userTracker.whoIsThere(projected);
    return [NSNumber numberWithInt:user];
}
-(id)positionOfUser:(NSNumber*) userId joint:(NSString*) jointName{
    return userTracker.positionOfJoint([userId intValue], jointName);
}
-(void)trackHand:(id)object{
    if(![object isKindOfClass:[WebScriptObject class]])
        return;
    WebScriptObject *obj = (WebScriptObject*)object;
    XnPoint3D pos;
    id xThing = [obj valueForKey:@"x"];
    if([xThing isKindOfClass:[NSNumber class]]){
        pos.X = [xThing floatValue];
    }
    id yThing = [obj valueForKey:@"y"];
    if([yThing isKindOfClass:[NSNumber class]]){
        pos.Y= [yThing floatValue];
    }
    id zThing = [obj valueForKey:@"z"];
    if([zThing isKindOfClass:[NSNumber class]]){
        pos.Z= [zThing floatValue];
    }
    //handTracker.startTracking(pos);
}
-(id) getKey:(NSString*)key fromObj:(WebScriptObject*)obj{
    @try{
       return [obj valueForKey:key];
    } @catch (NSException *e) {
       return nil;
    }
    
}
-(void)style:(id)object{
    if(![object isKindOfClass:[WebScriptObject class]])
        return;
    WebScriptObject *obj = (WebScriptObject*)object;
    id num;
    
    num = [self getKey:@"top" fromObj:obj];
    if(num){
        y = [num intValue];
        top = YES;
    }
    num = [self getKey:@"bottom" fromObj:obj];
    if(num){
        y = [num intValue];
        top = NO;
    }
    num = [self getKey:@"left" fromObj:obj];
    if(num){
        x = [num intValue];
        left = YES;
    }
    num = [self getKey:@"right" fromObj:obj];
    if(num ){
        x = [num intValue];
        left = NO;
    }
    num = [self getKey:@"width" fromObj:obj];
    if(num ){
        width = [num intValue];
    }
    num = [self getKey:@"height" fromObj:obj];
    if(num ){
        height = [num intValue];
    }
    num = [self getKey:@"aR" fromObj:obj];
    if(num ){
        aR = [num intValue];
    }
    num = [self getKey:@"aG" fromObj:obj];
    if(num ){
        aG = [num intValue];
    }
    num = [self getKey:@"aB" fromObj:obj];
    if(num ){
        aB = [num intValue];
    }
    num = [self getKey:@"bR" fromObj:obj];
    if(num ){
        bR = [num intValue];
    }
    num = [self getKey:@"bG" fromObj:obj];
    if(num ){
        bG = [num intValue];
    }
    num = [self getKey:@"bB" fromObj:obj];
    if(num ){
        bB = [num intValue];
    }

    
    num = [self getKey:@"uR" fromObj:obj];
    if(num ){
        uR = [num intValue];
    }
    num = [self getKey:@"uG" fromObj:obj];
    if(num ){
        uG = [num intValue];
    }
    num = [self getKey:@"uB" fromObj:obj];
    if(num ){
        uB = [num intValue];
    }

    [self repositionTo:oldRect];
    
}


-(void) startKinect{
    XnStatus rc;
    
	EnumerationErrors errors;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"kinect_config" ofType:@"xml"];
    const char * xmlPath = [path UTF8String];
    
    xn::ScriptNode g_scriptNode;
	rc = g_context.InitFromXmlFile(xmlPath, g_scriptNode, &errors);
	if (rc == XN_STATUS_NO_NODE_PRESENT)
	{
		XnChar strError[1024];
		errors.ToString(strError, 1024);
		printf("%s\n", strError);
		return;
	}
	else if (rc != XN_STATUS_OK)
	{
		printf("Open failed: %s\n", xnGetStatusString(rc));
		return;
	}
    
	rc = g_context.FindExistingNode(XN_NODE_TYPE_DEPTH, g_depth);
	if (rc != XN_STATUS_OK)
	{
		printf("No depth node exists! Check your XML.");
		return;
	}
    
	rc = g_context.FindExistingNode(XN_NODE_TYPE_IMAGE, g_image);
	if (rc != XN_STATUS_OK)
	{
		printf("No image node exists! Check your XML.");
		return;
	}
    
	g_depth.GetMetaData(g_depthMD);
	g_image.GetMetaData(g_imageMD);
    
	// Hybrid mode isn't supported in this sample
	if (g_imageMD.FullXRes() != g_depthMD.FullXRes() || g_imageMD.FullYRes() != g_depthMD.FullYRes())
	{
		printf ("The device depth and image resolution must be equal!\n");
		return;
	}
    
	// RGB is the only image format supported.
	if (g_imageMD.PixelFormat() != XN_PIXEL_FORMAT_RGB24)
	{
		printf("The device image format must be RGB24\n");
		return;
	}
    
	// Texture map init
	g_nTexMapX = (((unsigned short)(g_depthMD.FullXRes()-1) / 512) + 1) * 512;
	g_nTexMapY = (((unsigned short)(g_depthMD.FullYRes()-1) / 512) + 1) * 512;
	g_pTexMap = (XnRGB24Pixel*)malloc(g_nTexMapX * g_nTexMapY * sizeof(XnRGB24Pixel));
    
    
    kinect_ready = YES;
    [self setupGenerators];
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.1];
}

-(void) setupGenerators{
    userTracker.Init(&g_context);
    userTracker.web = _web;
    
    //gestureTracker.Init(&g_context);
    //gestureTracker.web = _web;
    
    //handTracker.Init(&g_context);
    //handTracker.web = _web;
    
    userTracker.Run();
    //gestureTracker.Run();
    //handTracker.Run();
}

-(void) refresh:(id)hop
{
    [self updateKinect];
    [self setNeedsDisplay:YES];
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.03];
}

-(void) ScalePoint:(XnPoint3D&)point
{
	point.X *= self.frame.size.width;
	point.X /= g_depthMD.XRes();
    
	point.Y *= self.frame.size.height;
	point.Y /= g_depthMD.YRes();
}

-(void) updateKinect{
    if(!kinect_ready){
        return;
    }
    XnStatus rc = XN_STATUS_OK;
    
	// Read a new frame
	rc = g_context.WaitAndUpdateAll();
	if (rc != XN_STATUS_OK)
	{
		printf("Read failed: %s\n", xnGetStatusString(rc));
		return;
	}
    
	g_depth.GetMetaData(g_depthMD);
	g_image.GetMetaData(g_imageMD);

}

-(void) drawRect: (NSRect) bounds
{
    if(!kinect_ready){
        return;
    }
    glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
    
	const XnDepthPixel* pDepth = g_depthMD.Data();
    
	// Copied from SimpleViewer
	
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
	// Setup the OpenGL viewpoint
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, self.frame.size.width, self.frame.size.height, 0, -1.0, 1.0);
    
	// Calculate the accumulative histogram (the yellow display...)
	xnOSMemSet(g_pDepthHist, 0, MAX_DEPTH*sizeof(float));
    
	unsigned int nNumberOfPoints = 0;
	for (XnUInt y = 0; y < g_depthMD.YRes(); ++y)
	{
		for (XnUInt x = 0; x < g_depthMD.XRes(); ++x, ++pDepth)
		{
			if (*pDepth != 0)
			{
				g_pDepthHist[*pDepth]++;
				nNumberOfPoints++;
			}
		}
	}
	for (int nIndex=1; nIndex<MAX_DEPTH; nIndex++)
	{
		g_pDepthHist[nIndex] += g_pDepthHist[nIndex-1];
	}
	if (nNumberOfPoints)
	{
		for (int nIndex=1; nIndex<MAX_DEPTH; nIndex++)
		{
			g_pDepthHist[nIndex] = (unsigned int)(256 * (1.0f - (g_pDepthHist[nIndex] / nNumberOfPoints)));
		}
	}
    
	xnOSMemSet(g_pTexMap, 0, g_nTexMapX*g_nTexMapY*sizeof(XnRGB24Pixel));
    const XnDepthPixel* pDepthRow = g_depthMD.Data();
    XnRGB24Pixel* pTexRow = g_pTexMap + g_depthMD.YOffset() * g_nTexMapX;
    int ar = aR;
    int ag = aG;
    int ab = aB;
    int br = bR;
    int bg = bG;
    int bb = bB;
    
    const XnLabel* userPixels = userTracker.firstUserPixels();
    if(userPixels==nil){
        for (XnUInt y = 0; y < g_depthMD.YRes(); ++y)
        {
            const XnDepthPixel* pDepth = pDepthRow;
            XnRGB24Pixel* pTex = pTexRow + g_depthMD.XOffset();
            
            for (XnUInt x = 0; x < g_depthMD.XRes(); ++x, ++pDepth, ++pTex)
            {
                if (*pDepth != 0)
                {
                    int nHistValue = g_pDepthHist[*pDepth];
                    float ratio = (255-nHistValue)/255.0;
                    pTex->nRed = ar*ratio+br*(1-ratio);
                    pTex->nGreen = ag*ratio+bg*(1-ratio);
                    pTex->nBlue = ab*ratio+bb*(1-ratio);
                }else{
                    pTex->nRed = ar;
                    pTex->nGreen = ag;
                    pTex->nBlue = ab;
                }
            }	            
            pDepthRow += g_depthMD.XRes();
            pTexRow += g_nTexMapX;
        }
    }else{
        for (XnUInt y = 0; y < g_depthMD.YRes(); ++y)
        {
            const XnDepthPixel* pDepth = pDepthRow;
            XnRGB24Pixel* pTex = pTexRow + g_depthMD.XOffset();
            
            for (XnUInt x = 0; x < g_depthMD.XRes(); ++x, ++pDepth, ++pTex, ++userPixels)
            {
                if (*pDepth != 0)
                {
                    if(*userPixels==activeUserId){
                        int nHistValue = g_pDepthHist[*pDepth];
                        float ratio = (255-nHistValue)/255.0;
                        pTex->nRed = ar*ratio+uR*(1-ratio);
                        pTex->nGreen = ag*ratio+uG*(1-ratio);
                        pTex->nBlue = ab*ratio+uB*(1-ratio);
                    }else{
                        int nHistValue = g_pDepthHist[*pDepth];
                        float ratio = (255-nHistValue)/255.0;
                        if(*userPixels==0){
                            ratio=fmin(1.0,ratio*1.4);
                        }
                        pTex->nRed = ar*ratio+br*(1-ratio);
                        pTex->nGreen = ag*ratio+bg*(1-ratio);
                        pTex->nBlue = ab*ratio+bb*(1-ratio);
                    }
                }else{
                    pTex->nRed = ar;
                    pTex->nGreen = ag;
                    pTex->nBlue = ab;
                }
            }
            
            pDepthRow += g_depthMD.XRes();
            pTexRow += g_nTexMapX;
        }
    }
    
	// Create the OpenGL texture map
	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, g_nTexMapX, g_nTexMapY, 0, GL_RGB, GL_UNSIGNED_BYTE, g_pTexMap);
    
	// Display the OpenGL texture map
	glColor4f(1,1,1,1);
    
	glBegin(GL_QUADS);
    
	int nXRes = g_depthMD.FullXRes();
	int nYRes = g_depthMD.FullYRes();
    
	// upper left
	glTexCoord2f(0, 0);
	glVertex2f(0, 0);
	// upper right
	glTexCoord2f((float)nXRes/(float)g_nTexMapX, 0);
	glVertex2f(self.frame.size.width, 0);
	// bottom right
	glTexCoord2f((float)nXRes/(float)g_nTexMapX, (float)nYRes/(float)g_nTexMapY);
	glVertex2f(self.frame.size.width, self.frame.size.height);
	// bottom left
	glTexCoord2f(0, (float)nYRes/(float)g_nTexMapY);
	glVertex2f(0, self.frame.size.height);
    
	glEnd();
    glDisable(GL_TEXTURE_2D);
    glFlush();
    
}

@end

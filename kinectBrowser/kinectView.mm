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

#define LENGTHOF(arr)			(sizeof(arr)/sizeof(arr[0]))

@implementation kinectView

@synthesize app;

- (void)awakeFromNib {
    kinect_ready = NO;
    XnStatus rc;
    
	EnumerationErrors errors;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"kinect_config" ofType:@"xml"];
    const char * xmlPath = [path UTF8String];
    
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
    
    g_nViewState = DISPLAY_MODE_OVERLAY;
    g_nViewState = DISPLAY_MODE_DEPTH;
    
    kinect_ready = YES;
    
    handtracker.Init(&g_context);
    handtracker.kinectv = self;
    handtracker.Run();
    
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.1];
}

-(void) refresh:(id)hop
{
    [self setNeedsDisplay:YES];
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.03];
}

-(void) ScalePoint:(XnPoint3D&)point
{
	point.X *= GL_WIN_SIZE_X;
	point.X /= g_depthMD.XRes();
    
	point.Y *= GL_WIN_SIZE_Y;
	point.Y /= g_depthMD.YRes();
}
-(void) drawHand
{
    typedef TrailHistory			History;
	typedef History::ConstIterator	HistoryIterator;
	typedef History::Trail			Trail;
	typedef Trail::ConstIterator	TrailIterator;

	const TrailHistory&	history = handtracker.GetHistory();
    
	// History points coordinates buffer
	XnFloat	coordinates[3 * MAX_HAND_TRAIL_LENGTH];
    
    HistoryIterator	hend = history.end();
	for(HistoryIterator		hit = history.begin(); hit != hend; ++hit)
	{
        
		// Dump the history to local buffer
		int				numpoints = 0;
        Trail&	trail = hit.GetTrail();
        
		const TrailIterator	tend = trail.end();
        if(trail.isSteady()){
            glColor3f(1.0f, 0.05f, 1.35f);
        }else{
                glColor3f(0.0f, 1.05f, 0.35f);
        }
        //glBegin(GL_LINE_STRIP);
		for(TrailIterator	tit = trail.begin(); tit != tend; ++tit)
		{
			XnPoint3D	point = *tit;
			g_depth.ConvertRealWorldToProjective(1, &point, &point);
            [self ScalePoint:point];
            //glVertex3d(point.X,point.Y,0.0);
			coordinates[numpoints * 3] = point.X;
			coordinates[numpoints * 3 + 1] = point.Y;
			coordinates[numpoints * 3 + 2] = 0;
            
			++numpoints;
		}
        //glEnd();
        int status = trail.getStatus();
        if(status==1){
            [app sweepUp:self];
        }
        if(status==2){
            [app sweepDown:self];
        }
        // #f64744 246 71 68
        glColor3f(0.96f, 0.27f, 0.26f);
        glBegin(GL_TRIANGLES);
        {
            glVertex3f(  coordinates[0]-5,  coordinates[1]-5, 0.0);
            glVertex3f(  coordinates[0]+5,  coordinates[1]+5, 0.0);
            glVertex3f(  coordinates[0]+5,  coordinates[1]-5, 0.0);
            
            glVertex3f(  coordinates[0]-5,  coordinates[1]-5, 0.0);
            glVertex3f(  coordinates[0]+5,  coordinates[1]+5, 0.0);
            glVertex3f(  coordinates[0]-5,  coordinates[1]+5, 0.0);
        }
        glEnd();
		assert(numpoints <= MAX_HAND_TRAIL_LENGTH);
        glFlush();
	}
}

-(void) drawRect: (NSRect) bounds
{
    glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
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
    
	const XnDepthPixel* pDepth = g_depthMD.Data();
    
	// Copied from SimpleViewer
	
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
	// Setup the OpenGL viewpoint
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, GL_WIN_SIZE_X, GL_WIN_SIZE_Y, 0, -1.0, 1.0);
    /*glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  100.0, 0.0);
        glVertex3f( 100.2, 100.3, 0.0);
        glVertex3f(  50.2, 50.3 ,0.0);
    }
    glEnd();*/
    
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
    
	// check if we need to draw image frame to texture
	if (g_nViewState == DISPLAY_MODE_OVERLAY ||
		g_nViewState == DISPLAY_MODE_IMAGE)
	{
		const XnRGB24Pixel* pImageRow = g_imageMD.RGB24Data();
		XnRGB24Pixel* pTexRow = g_pTexMap + g_imageMD.YOffset() * g_nTexMapX;
        
		for (XnUInt y = 0; y < g_imageMD.YRes(); ++y)
		{
			const XnRGB24Pixel* pImage = pImageRow;
			XnRGB24Pixel* pTex = pTexRow + g_imageMD.XOffset();
            
			for (XnUInt x = 0; x < g_imageMD.XRes(); ++x, ++pImage, ++pTex)
			{
				*pTex = *pImage;
			}
            
			pImageRow += g_imageMD.XRes();
			pTexRow += g_nTexMapX;
		}
	}
    
	// check if we need to draw depth frame to texture
	if (g_nViewState == DISPLAY_MODE_OVERLAY ||
		g_nViewState == DISPLAY_MODE_DEPTH)
	{
		const XnDepthPixel* pDepthRow = g_depthMD.Data();
		XnRGB24Pixel* pTexRow = g_pTexMap + g_depthMD.YOffset() * g_nTexMapX;
        int ar = 62;
        int ag = 63;
        int ab = 47;
        int br = 252;
        int bg = 253;
        int bb = 248;
        
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
	glVertex2f(GL_WIN_SIZE_X, 0);
	// bottom right
	glTexCoord2f((float)nXRes/(float)g_nTexMapX, (float)nYRes/(float)g_nTexMapY);
	glVertex2f(GL_WIN_SIZE_X, GL_WIN_SIZE_Y);
	// bottom left
	glTexCoord2f(0, (float)nYRes/(float)g_nTexMapY);
	glVertex2f(0, GL_WIN_SIZE_Y);
    
	glEnd();
    glDisable(GL_TEXTURE_2D);
    [self drawHand];
    glFlush();
    
}

-(void)handLostId:(int)nId{
    [app handLostId:nId];
}
-(void)handId:(int)nId Pont:(XnPoint3D) point{
    //g_depth.ConvertRealWorldToProjective(1, &point, &point);
    //[self ScalePoint:point];
    [app handId:nId X:point.X Y:point.Y Z:point.Z];
}

@end

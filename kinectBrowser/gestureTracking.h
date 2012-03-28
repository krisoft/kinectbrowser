//
//  userTracking.h
//  kinectBrowser
//
//  Created by Gergely Krisztian on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <XnCppWrapper.h>
#import <WebKit/WebKit.h>


class GestureTracker
{
public:
	XnStatus Init(xn::Context* context);
	XnStatus Run();
    WebView *web;
    
private:
    static void XN_CALLBACK_TYPE GestureRecognized (xn::GestureGenerator &generator, const XnChar *strGesture, const XnPoint3D *pIDPosition, const XnPoint3D *pEndPosition, void *pCookie);
    static void XN_CALLBACK_TYPE GestureProgress (xn::GestureGenerator &generator, const XnChar *strGesture, const XnPoint3D *pPosition, XnFloat fProgress, void *pCookie);

	xn::Context*			m_rContext;
	xn::GestureGenerator    m_GestureGenerator;
};
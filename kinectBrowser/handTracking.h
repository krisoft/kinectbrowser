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


class HandTracker
{
public:
	XnStatus Init(xn::Context* context);
	XnStatus Run();
    WebView *web;
    void startTracking(XnPoint3D point);
    
private:
    
    static void XN_CALLBACK_TYPE HandCreate(xn::HandsGenerator &generator, XnUserID user, const XnPoint3D *pPosition, XnFloat fTime, void *pCookie);
    static  void XN_CALLBACK_TYPE HandUpdate(xn::HandsGenerator &generator, XnUserID user, const XnPoint3D *pPosition, XnFloat fTime, void *pCookie);
    static  void XN_CALLBACK_TYPE HandDestroy(xn::HandsGenerator &generator, XnUserID user, XnFloat fTime, void *pCookie);

    
	xn::Context*			m_rContext;
	xn::HandsGenerator    m_HandGenerator;
};
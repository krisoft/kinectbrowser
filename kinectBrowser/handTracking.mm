//
//  userTracking.m
//  kinectBrowser
//
//  Created by Gergely Krisztian on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "handTracking.h"

void XN_CALLBACK_TYPE HandTracker::HandUpdate(xn::HandsGenerator &generator, XnUserID user, const XnPoint3D *pPosition, XnFloat fTime, void *pCookie){
    HandTracker* tracker = (HandTracker*)pCookie;
    NSString* script = [NSString stringWithFormat:@"kinectCallback.handMove({'handId':'%i','pos':{'x':%f,'y':%f,'z':%f}});",user,pPosition->X,pPosition->Y,pPosition->Z];
    [tracker->web stringByEvaluatingJavaScriptFromString:script];
}
void XN_CALLBACK_TYPE HandTracker::HandDestroy(xn::HandsGenerator &generator, XnUserID user, XnFloat fTime, void *pCookie){
    HandTracker* tracker = (HandTracker*)pCookie;
    NSString* script = [NSString stringWithFormat:@"kinectCallback.handLost(%i);",user];
    [tracker->web stringByEvaluatingJavaScriptFromString:script];
}


XnStatus HandTracker::Init(xn::Context* context)
{            
    m_rContext = context;
	XnStatus			rc;
    
	// Create generator    
	rc = m_HandGenerator.Create(*m_rContext);
	if (rc != XN_STATUS_OK)
	{
		printf("Unable to create UserGenerator.");
		return rc;
	}
    XnCallbackHandle hCallback;
    m_HandGenerator.RegisterHandCallbacks(HandUpdate, HandUpdate, HandDestroy, this, hCallback);
	return XN_STATUS_OK;
}

XnStatus HandTracker::Run()
{
    
	XnStatus	rc = m_rContext->StartGeneratingAll();
	if (rc != XN_STATUS_OK)
	{
		printf("Unable to start generating.\n");
		return rc;
	}
	return XN_STATUS_OK;
}

void HandTracker::startTracking(XnPoint3D point){
    m_HandGenerator.StartTracking(point);
}



//
//  userTracking.m
//  kinectBrowser
//
//  Created by Gergely Krisztian on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "gestureTracking.h"

void XN_CALLBACK_TYPE GestureTracker::GestureRecognized (xn::GestureGenerator &generator, const XnChar *strGesture, const XnPoint3D *pIDPosition, const XnPoint3D *pEndPosition, void *pCookie){
    GestureTracker* tracker = (GestureTracker*)pCookie;
    NSString* script = [NSString stringWithFormat:@"kinectCallback.gestureRecognized({'gesture':'%s','pos':{'x':%f,'y':%f,'z':%f}});",strGesture,pEndPosition->X,pEndPosition->Y,pEndPosition->Z];
    [tracker->web stringByEvaluatingJavaScriptFromString:script];
}
void XN_CALLBACK_TYPE GestureTracker::GestureProgress (xn::GestureGenerator &generator, const XnChar *strGesture, const XnPoint3D *pPosition, XnFloat fProgress, void *pCookie){
    GestureTracker* tracker = (GestureTracker*)pCookie;
    NSString* script = [NSString stringWithFormat:@"kinectCallback.gestureProgress({'gesture':'%s','pos':{'x':%f,'y':%f,'z':%f},'progress':%f});",strGesture,pPosition->X,pPosition->Y,pPosition->Z,fProgress];
    [tracker->web stringByEvaluatingJavaScriptFromString:script];

}

XnStatus GestureTracker::Init(xn::Context* context)
{            
    m_rContext = context;
	XnStatus			rc;
    
	// Create generator    
	rc = m_GestureGenerator.Create(*m_rContext);
	if (rc != XN_STATUS_OK)
	{
		printf("Unable to create UserGenerator.");
		return rc;
	}
    XnCallbackHandle hCallback;
    m_GestureGenerator.RegisterGestureCallbacks(GestureRecognized, GestureProgress, this, hCallback);
    if(m_GestureGenerator.AddGesture("Wave", NULL) != XN_STATUS_OK){
        printf("Unable to add gesture"); exit(1);
    }
    if(m_GestureGenerator.AddGesture("RaiseHand", NULL) != XN_STATUS_OK){
        printf("Unable to add gesture"); exit(1);
    }
    if(m_GestureGenerator.AddGesture("Click", NULL) != XN_STATUS_OK){
        printf("Unable to add gesture"); exit(1);
    }
	return XN_STATUS_OK;
}

XnStatus GestureTracker::Run()
{
    
	XnStatus	rc = m_rContext->StartGeneratingAll();
	if (rc != XN_STATUS_OK)
	{
		printf("Unable to start generating.\n");
		return rc;
	}
	return XN_STATUS_OK;
}



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


class UserTracker
{
public:
	XnStatus Init(xn::Context* context);
	XnStatus Run();
    WebView *web;
    xn::UserGenerator       m_UserGenerator;
    NSArray* positionOfUser(int userId);
    NSArray* positionOfJoint(int userId,NSString* jointName);
    NSArray* getUsers();
    NSArray* getTrackedUsers();
    
    int whoIsThere(XnPoint3D &there);
    const XnLabel* firstUserPixels();
private:
    static void XN_CALLBACK_TYPE NewUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie);
    static void XN_CALLBACK_TYPE LostUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie);
    static void XN_CALLBACK_TYPE ExitUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie);
    static void XN_CALLBACK_TYPE ReEnterUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie);
    static void XN_CALLBACK_TYPE CalibrationComplete(xn::SkeletonCapability& capability, XnUserID nId, XnCalibrationStatus eStatus, void* pCookie);
	xn::Context*			m_rContext;
};
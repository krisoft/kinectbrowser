//
//  userTracking.m
//  kinectBrowser
//
//  Created by Gergely Krisztian on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "userTracking.h"

void XN_CALLBACK_TYPE UserTracker::NewUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie){
    printf("new user %i\n",nId);
    UserTracker* tracker = (UserTracker*)pCookie;
    [tracker->web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"kinectCallback.newUser(%i);",nId]];
    (tracker->m_UserGenerator).GetSkeletonCap().RequestCalibration(nId,true);
    
    
}
void XN_CALLBACK_TYPE UserTracker::LostUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie){
    printf("lost user %i\n",nId);
    UserTracker* tracker = (UserTracker*)pCookie;
    [tracker->web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"kinectCallback.lostUser(%i);",nId]];
}
void XN_CALLBACK_TYPE UserTracker::ExitUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie){
    printf("user exit %i\n",nId);
    UserTracker* tracker = (UserTracker*)pCookie;
    [tracker->web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"kinectCallback.exitUser(%i);",nId]];
    (tracker->m_UserGenerator).GetSkeletonCap().StopTracking(nId);
}
void XN_CALLBACK_TYPE UserTracker::ReEnterUser(xn::UserGenerator& generator, XnUserID nId, void* pCookie){
    printf("lost reenter %i\n",nId);
    UserTracker* tracker = (UserTracker*)pCookie;
    [tracker->web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"kinectCallback.reEnterUser(%i);",nId]];
    (tracker->m_UserGenerator).GetSkeletonCap().RequestCalibration(nId,true);
}
void XN_CALLBACK_TYPE UserTracker::CalibrationComplete(xn::SkeletonCapability& capability, XnUserID nId, XnCalibrationStatus eStatus, void* pCookie){
    UserTracker* tracker = (UserTracker*)pCookie;
    if (eStatus == XN_CALIBRATION_STATUS_OK)
	{
		// Calibration succeeded		
		XnStatus rc = (tracker->m_UserGenerator).GetSkeletonCap().StartTracking(nId);
	}
	else
	{
		// Calibration failed
        if(eStatus==XN_CALIBRATION_STATUS_MANUAL_ABORT)
        {
            return;
        }
        (tracker->m_UserGenerator).GetSkeletonCap().RequestCalibration(nId, TRUE);
	}
}

XnStatus UserTracker::Init(xn::Context* context)
{            
    m_rContext = context;
	XnStatus			rc;
    
	// Create generator    
	rc = m_UserGenerator.Create(*m_rContext);
	if (rc != XN_STATUS_OK)
	{
		printf("Unable to create UserGenerator.");
		return rc;
	}
    XnCallbackHandle hCallback;
    m_UserGenerator.RegisterUserCallbacks(NewUser, LostUser, this,hCallback);
    m_UserGenerator.RegisterToUserExit(ExitUser, this, hCallback);
    m_UserGenerator.RegisterToUserReEnter(ReEnterUser, this, hCallback);
    m_UserGenerator.GetSkeletonCap().RegisterToCalibrationComplete(CalibrationComplete, this, hCallback);
    m_UserGenerator.GetSkeletonCap().SetSkeletonProfile(XN_SKEL_PROFILE_ALL);

	return XN_STATUS_OK;
}

XnStatus UserTracker::Run()
{
    
	XnStatus	rc = m_rContext->StartGeneratingAll();
	if (rc != XN_STATUS_OK)
	{
		printf("Unable to start generating.\n");
		return rc;
	}
	return XN_STATUS_OK;
}

NSArray* UserTracker::positionOfUser(int userId){
    XnPoint3D pos;
    XnStatus			rc;
    rc = m_UserGenerator.GetCoM(userId, pos);
    if (rc != XN_STATUS_OK)
	{
        NSLog(@"posUser error %i",userId);
    }

    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:pos.X],[NSNumber numberWithFloat:pos.Y],[NSNumber numberWithFloat:pos.Z], nil];
}
NSArray* UserTracker::positionOfJoint(int userId,NSString* jointName){
    xn::SkeletonCapability skeleton = m_UserGenerator.GetSkeletonCap();
    if(!skeleton.IsTracking(userId)){
        return Nil;
    }
    XnSkeletonJoint joint;
    if([jointName isEqualToString:@"torso"]){
        joint = XN_SKEL_TORSO;
    }
    if([jointName isEqualToString:@"head"]){
        joint = XN_SKEL_HEAD;
    }
    if([jointName isEqualToString:@"neck"]){
        joint = XN_SKEL_NECK;
    }
    if([jointName isEqualToString:@"waist"]){
        joint = XN_SKEL_WAIST;
    }
    if([jointName isEqualToString:@"left_elbow"]){
        joint = XN_SKEL_LEFT_ELBOW;
    }
    if([jointName isEqualToString:@"left_wrist"]){
        joint = XN_SKEL_LEFT_WRIST;
    }
    if([jointName isEqualToString:@"left_hand"]){
        joint = XN_SKEL_LEFT_HAND;
    }        	
    if([jointName isEqualToString:@"right_elbow"]){
        joint = XN_SKEL_RIGHT_ELBOW;
    }
    if([jointName isEqualToString:@"right_wrist"]){
        joint = XN_SKEL_RIGHT_WRIST;
    }
    if([jointName isEqualToString:@"right_hand"]){
        joint = XN_SKEL_RIGHT_HAND;
    }        	
    if([jointName isEqualToString:@"right_hand"]){
        joint = XN_SKEL_RIGHT_HAND;
    }
    XnSkeletonJointPosition pos;
    skeleton.GetSkeletonJointPosition(userId, joint, pos);
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:pos.position.X],[NSNumber numberWithFloat:pos.position.Y],[NSNumber numberWithFloat:pos.position.Z], nil];
}
NSArray* UserTracker::getUsers(){
    XnUInt16 num = m_UserGenerator.GetNumberOfUsers();
    XnUserID aUsers[num];
    XnStatus			rc;
    rc = m_UserGenerator.GetUsers((XnUserID*)aUsers,num);
    if (rc != XN_STATUS_OK) return nil;
    NSMutableArray * resultArray = [[NSMutableArray alloc] initWithCapacity: num];
    for(int i=0;i<num;i++){
        [resultArray addObject: [NSNumber numberWithInt:aUsers[i]]];
    }
    return resultArray;
}
NSArray* UserTracker::getTrackedUsers(){
    XnUInt16 num = m_UserGenerator.GetNumberOfUsers();
    XnUserID aUsers[num];
    int userOk[num];
    int trackedNum = 0;
    XnStatus			rc;
    rc = m_UserGenerator.GetUsers((XnUserID*)aUsers,num);
    xn::SkeletonCapability skeleton = m_UserGenerator.GetSkeletonCap();
    for(int i=0;i<num;i++){
        if(skeleton.IsTracking(aUsers[i])){
            userOk[i] = 1;
            trackedNum += 1;
        }else{
            userOk[i] = 0;
        }
    }
    if(trackedNum==0){
        return Nil;
    }
    NSMutableArray* resultArray = [[NSMutableArray alloc] initWithCapacity: trackedNum];
    for(int i=0;i<num;i++){
        if(userOk[i]==1){
            [resultArray addObject: [NSNumber numberWithInt:aUsers[i]]];
        }
    }
    return resultArray;
}

int UserTracker::whoIsThere(XnPoint3D &there){
    int x = int(there.X);
    int y = int(there.Y);
    XnUInt16 num = m_UserGenerator.GetNumberOfUsers();
    XnUserID aUsers[num];
    XnStatus			rc;
    rc = m_UserGenerator.GetUsers((XnUserID*)aUsers,num);
    if (rc != XN_STATUS_OK) return -1;
    for(int i=0;i<num;i++){
        xn::SceneMetaData smd;
        rc = m_UserGenerator.GetUserPixels(aUsers[i], smd);
        if (rc != XN_STATUS_OK) return -1;
        if(smd(x,y)!=0){
            return smd(x,y);
        }
    }
    
    return -1;
}

const XnLabel* UserTracker::firstUserPixels(){
    XnUInt16 num = m_UserGenerator.GetNumberOfUsers();
    XnUserID aUsers[num];
    XnStatus			rc;
    rc = m_UserGenerator.GetUsers((XnUserID*)aUsers,num);
    if (rc != XN_STATUS_OK || num<1) return nil;
    xn::SceneMetaData smd;
    rc = m_UserGenerator.GetUserPixels(aUsers[0], smd);
    if (rc != XN_STATUS_OK) return nil;
    return smd.Data();
}




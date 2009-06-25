//
//  SDFacebookTask.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 6/7/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDFacebookTaskManager;

#import "SDNetTask.h"

typedef enum _SDFacebookTaskType {
	SDFacebookTaskDoNothing,
	
	SDFacebookTaskGetLoginURL,
	SDFacebookTaskFinishLoginProcess,
	
	SDFacebookTaskGetFriends,
	SDFacebookTaskGetUserInfo,
	
	SDFacebookTaskGetPublicTimeline,
	
	SDFacebookTaskMAX // leave this alone
} SDFacebookTaskType;

@interface SDFacebookTask : SDNetTask {
	SDFacebookTaskManager *facebookManager;
	
	NSArray *UIDs;
}

@property (copy) NSArray *UIDs;

@end

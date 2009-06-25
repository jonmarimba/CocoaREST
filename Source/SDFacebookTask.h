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
	
	SDFacebookTaskGetAppPermissions,
	SDFacebookTaskGetAllowAppPermissionsURL,
	
	SDFacebookTaskGetFriends,
	SDFacebookTaskGetUserInfo,
	
	SDFacebookTaskGetNotes,
	SDFacebookTaskEditNote,
	
	SDFacebookTaskGetPublicTimeline,
	
	SDFacebookTaskMAX // leave this alone
} SDFacebookTaskType;

@interface SDFacebookTask : SDNetTask {
	SDFacebookTaskManager *facebookManager;
	
	NSArray *UIDs;
	
	NSString *noteID;
	NSString *title;
	NSString *content;
	
	NSString *appPermissionType;
}

@property (copy) NSArray *UIDs;

@property (copy) NSString *noteID;
@property (copy) NSString *title;
@property (copy) NSString *content;

@property (copy) NSString *appPermissionType;

@end

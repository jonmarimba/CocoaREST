//
//  SDFriendfeedTask.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 6/2/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTask.h"

typedef enum _SDFriendfeedTaskType {
	SDFriendfeedTaskDoNothing,
	
	SDFriendfeedTaskGetPublicTimeline,
	SDFriendfeedTaskGetUserPicture,
	
	SDFriendfeedTaskMAX // leave this alone
} SDFriendfeedTaskType;

@interface SDFriendfeedTask : SDNetTask {
	NSString *username;
}

@property (copy) NSString *username;

@end

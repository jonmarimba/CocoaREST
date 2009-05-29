//
//  SDTwitterFetchTask.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkTaskDelegateProtocol.h"

@class SDSocialNetworkManager;

typedef enum _SDSocialNetworkService {
	SDSocialNetworkServiceTwitter
} SDSocialNetworkService;

typedef enum _SDSocialNetworkTaskType {
	
	SDSocialNetworkTaskDoNothing,
	
	SDSocialNetworkTaskGetPublicTimeline,
	SDSocialNetworkTaskGetPersonalTimeline,
	SDSocialNetworkTaskGetUsersTimeline,
	SDSocialNetworkTaskGetMentions,
	
	SDSocialNetworkTaskGetStatus,
	SDSocialNetworkTaskCreateStatus,
	SDSocialNetworkTaskDeleteStatus,
	
	SDSocialNetworkTaskGetUserInfo,
	SDSocialNetworkTaskGetUsersFriends,
	SDSocialNetworkTaskGetUsersFollowers,
	
	SDSocialNetworkTaskGetReceivedDirectMessages,
	SDSocialNetworkTaskGetSentDirectMessages,
	SDSocialNetworkTaskCreateDirectMessage,
	SDSocialNetworkTaskDeleteDirectMessage,
	
	SDSocialNetworkTaskFollowUser,
	SDSocialNetworkTaskUnfollowUser,
	SDSocialNetworkTaskCheckIfUserFollowsUser, // has no param ivars yet
	
	SDSocialNetworkTaskGetIDsOfFriends,
	SDSocialNetworkTaskGetIDsOfFollowers,
	
	SDSocialNetworkTaskVerifyCredentials,
	SDSocialNetworkTaskUpdateDeliveryDevice, // has no param ivars yet
	SDSocialNetworkTaskUpdateProfileColors, // has no param ivars yet
	SDSocialNetworkTaskUpdateProfileImage, // broken for the moment
	SDSocialNetworkTaskUpdateProfileBackgroundImage, // broken for the moment
	SDSocialNetworkTaskUpdateProfile, // has no params ivars yet
	
	SDSocialNetworkTaskGetFavoriteStatuses,
	SDSocialNetworkTaskFavorStatus,
	SDSocialNetworkTaskUnavorStatus,
	
	SDSocialNetworkTaskEnableDeviceNotificationsFromUser,
	SDSocialNetworkTaskDisableDeviceNotificationsFromUser,
	
	SDSocialNetworkTaskBlockUser,
	SDSocialNetworkTaskUnblockUser,
	SDSocialNetworkTaskCheckIfBlockingUser,
	SDSocialNetworkTaskGetBlockedUsers,
	SDSocialNetworkTaskGetBlockedUserIDs,
	
	SDSocialNetworkTaskMAX // NEVER use this value (srsly... kthxbye)
	
} SDSocialNetworkTaskType;

typedef enum _SDSocialNetworkTaskError {
	SDSocialNetworkTaskErrorNone,
	SDSocialNetworkTaskErrorInvalidType,
	SDSocialNetworkTaskErrorManagerNotSet, // (must only use -runTask: to run a task!)
	SDSocialNetworkTaskErrorConnectionDataIsNil,
	SDSocialNetworkTaskErrorConnectionFailed,
	SDSocialNetworkTaskErrorParserFailed,
	SDSocialNetworkTaskErrorParserDataIsNil,
	
	SDSocialNetworkTaskErrorMAX // once again, don't touch.
} SDSocialNetworkTaskError;

@interface SDSocialNetworkTask : NSOperation {
	SDSocialNetworkManager *manager;
	
	NSString *taskID;
	id results;
	
	SDSocialNetworkTaskError errorCode;
	NSError *error;
	NSError *underlyingError;
	
	SDSocialNetworkService service;
	SDSocialNetworkTaskType type;
	
	int count;
	int page;
	
	NSString *text;
	
	NSString *olderThanStatusID;
	NSString *newerThanStatusID;
	NSString *inReplyToStatusID;
	
	NSString *statusID;
	NSString *userID;
	NSString *screenName;
	
	NSImage *imageToUpload;
}



// designated convenience initializer

+ (id) task;


// writable properties: set up before running

@property SDSocialNetworkService service;
@property SDSocialNetworkTaskType type;

@property int count;
@property int page;

@property (copy) NSString *text;

@property (copy) NSString *olderThanStatusID;
@property (copy) NSString *newerThanStatusID;
@property (copy) NSString *inReplyToStatusID;

@property (copy) NSString *statusID;
@property (copy) NSString *userID;
@property (copy) NSString *screenName;

@property (copy) NSImage *imageToUpload;


// readable properties: use after task is complete

@property (readonly) id results;

@property (readonly) SDSocialNetworkTaskError errorCode;
@property (readonly) NSError *error;

@property (readonly) NSString *taskID; // DEPRECATED; do not use unless you REALLY want to.

// leave alone: used inside -[SDSocialNetworkManager runSocialNetworkTask:] only
@property (assign) SDSocialNetworkManager *manager;

@end

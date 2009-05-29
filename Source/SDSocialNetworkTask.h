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
	SDSocialNetworkTaskCheckIfUserFollowsUser,
	
	SDSocialNetworkTaskGetIDsOfFriends,
	SDSocialNetworkTaskGetIDsOfFollowers,
	
	SDSocialNetworkTaskVerifyCredentials,
	SDSocialNetworkTaskUpdateDeliveryDevice,
	SDSocialNetworkTaskUpdateProfileColors,
	SDSocialNetworkTaskUpdateProfileImage, // broken for the moment
	SDSocialNetworkTaskUpdateProfileBackgroundImage, // broken for the moment
	SDSocialNetworkTaskUpdateProfile,
	
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

typedef enum _SDSocialNetworkDeviceType {
	SDSocialNetworkDeviceTypeNotYetSet,
	SDSocialNetworkDeviceTypeSMS,
	SDSocialNetworkDeviceTypeInstantMessage,
	SDSocialNetworkDeviceTypeNone
} SDSocialNetworkDeviceType;

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
	
	NSString *firstUsersID;
	NSString *secondUsersID;
	
	NSString *statusID;
	NSString *userID;
	NSString *screenName;
	
	NSString *profileName;
	NSString *profileEmail;
	NSString *profileWebsite;
	NSString *profileLocation;
	NSString *profileDescription;
	
	NSColor *profileBackgroundColor;
	NSColor *profileTextColor;
	NSColor *profileLinkColor;
	NSColor *profileSidebarFillColor;
	NSColor *profileSidebarBorderColor;
	
	BOOL enableDeviceNotificationsAlso;
	SDSocialNetworkDeviceType deviceType;
	
	BOOL shouldTileBackgroundImage;
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

@property (copy) NSString *firstUsersID;
@property (copy) NSString *secondUsersID;

@property (copy) NSString *statusID;
@property (copy) NSString *userID;
@property (copy) NSString *screenName;

@property (copy) NSString *profileName;
@property (copy) NSString *profileEmail;
@property (copy) NSString *profileWebsite;
@property (copy) NSString *profileLocation;
@property (copy) NSString *profileDescription;

@property (copy) NSColor *profileBackgroundColor;
@property (copy) NSColor *profileTextColor;
@property (copy) NSColor *profileLinkColor;
@property (copy) NSColor *profileSidebarFillColor;
@property (copy) NSColor *profileSidebarBorderColor;

@property BOOL enableDeviceNotificationsAlso;
@property SDSocialNetworkDeviceType deviceType;

@property BOOL shouldTileBackgroundImage;
@property (copy) NSImage *imageToUpload;


// readable properties: use after task is complete

@property (readonly) id results;

@property (readonly) SDSocialNetworkTaskError errorCode;
@property (readonly) NSError *error;

@property (readonly) NSString *taskID; // DEPRECATED; do not use unless you REALLY want to.

// leave alone: used inside -[SDSocialNetworkManager runSocialNetworkTask:] only
@property (assign) SDSocialNetworkManager *manager;

@end

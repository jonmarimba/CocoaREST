//
//  SDTwitterTask.h
//  SDNet
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTask.h"

@class SDTwitterManager;

typedef enum _SDTwitterTaskType {
	SDTwitterTaskDoNothing,
	
	SDTwitterTaskGetPublicTimeline,
	SDTwitterTaskGetPersonalTimeline,
	SDTwitterTaskGetUsersTimeline,
	SDTwitterTaskGetMentions,
	
	SDTwitterTaskGetStatus,
	SDTwitterTaskCreateStatus,
	SDTwitterTaskDeleteStatus,
	
	SDTwitterTaskGetUserInfo,
	SDTwitterTaskGetUsersFriends,
	SDTwitterTaskGetUsersFollowers,
	
	SDTwitterTaskGetReceivedDirectMessages,
	SDTwitterTaskGetSentDirectMessages,
	SDTwitterTaskCreateDirectMessage,
	SDTwitterTaskDeleteDirectMessage,
	
	SDTwitterTaskFollowUser,
	SDTwitterTaskUnfollowUser,
	SDTwitterTaskCheckIfUserFollowsUser,
	
	SDTwitterTaskGetIDsOfFriends,
	SDTwitterTaskGetIDsOfFollowers,
	
	SDTwitterTaskVerifyCredentials,
	SDTwitterTaskUpdateDeliveryDevice,
	SDTwitterTaskUpdateProfileColors,
	SDTwitterTaskUpdateProfileImage, // broken for the moment
	SDTwitterTaskUpdateProfileBackgroundImage, // broken for the moment
	SDTwitterTaskUpdateProfile,
	
	SDTwitterTaskGetFavoriteStatuses,
	SDTwitterTaskFavorStatus,
	SDTwitterTaskUnavorStatus,
	
	SDTwitterTaskEnableDeviceNotificationsFromUser,
	SDTwitterTaskDisableDeviceNotificationsFromUser,
	
	SDTwitterTaskBlockUser,
	SDTwitterTaskUnblockUser,
	SDTwitterTaskCheckIfBlockingUser,
	SDTwitterTaskGetBlockedUsers,
	SDTwitterTaskGetBlockedUserIDs,
	
	SDTwitterTaskMAX // NEVER use this value (srsly... kthxbye)
} SDTwitterTaskType;

typedef enum _SDTwitterDeviceType {
	SDTwitterDeviceTypeNotYetSet,
	SDTwitterDeviceTypeSMS,
	SDTwitterDeviceTypeInstantMessage,
	SDTwitterDeviceTypeNone
} SDTwitterDeviceType;

@interface SDTwitterTask : SDNetTask {
	SDTwitterManager *twitterManager;
	
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
	NSString *screenNameOrUserID;
	
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
	SDTwitterDeviceType deviceType;
	
	BOOL shouldTileBackgroundImage;
	NSImage *imageToUpload;
}

- (id) copyWithNextPage;

// writable properties: set up before running

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
@property (copy) NSString *screenNameOrUserID;

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
@property SDTwitterDeviceType deviceType;

@property BOOL shouldTileBackgroundImage;
@property (copy) NSImage *imageToUpload;

@end

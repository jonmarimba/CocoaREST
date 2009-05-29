//
//  SDTwitterTask.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDTwitterTask.h"

#import "SDTwitterManager.h"

#import "SDSocialNetworkTask+Subclassing.h"

@interface SDTwitterTask (Private)
@end


@implementation SDTwitterTask

@synthesize type;
@synthesize count;
@synthesize page;
@synthesize text;
@synthesize olderThanStatusID;
@synthesize newerThanStatusID;
@synthesize inReplyToStatusID;
@synthesize firstUsersID;
@synthesize secondUsersID;
@synthesize statusID;
@synthesize userID;
@synthesize screenName;
@synthesize enableDeviceNotificationsAlso;
@synthesize deviceType;
@synthesize profileName;
@synthesize profileEmail;
@synthesize profileWebsite;
@synthesize profileLocation;
@synthesize profileDescription;
@synthesize profileBackgroundColor;
@synthesize profileTextColor;
@synthesize profileLinkColor;
@synthesize profileSidebarFillColor;
@synthesize profileSidebarBorderColor;
@synthesize shouldTileBackgroundImage;
@synthesize imageToUpload;

- (id) initWithManager:(SDTwitterManager*)newManager {
	if (self = [super initWithManager:newManager]) {
		twitterManager = newManager;
		
		type = SDTwitterTaskDoNothing;
		errorCode = SDSocialNetworkTaskErrorNone;
		deviceType = SDTwitterDeviceTypeNotYetSet;
		
		page = 1;
		count = 0;
	}
	return self;
}

- (void) dealloc {
	[olderThanStatusID release], olderThanStatusID = nil;
	[newerThanStatusID release], newerThanStatusID = nil;
	
	[super dealloc];
}

+ (Protocol*) delegateProtocol {
	return @protocol(SDTwitterTaskDelegate);
}

- (void) sendResultsToDelegate {
	[(id)manager.delegate twitterManager:twitterManager resultsReadyForTask:self];
}

- (void) sendErrorToDelegate {
	[(id)manager.delegate twitterManager:twitterManager failedForTask:self];
}

- (BOOL) shouldUseBasicHTTPAuthentication {
	return YES;
}

// MARK: -
// MARK: Before-response Methods

- (BOOL) validateType {
	return (type > SDTwitterTaskDoNothing && type < SDTwitterTaskMAX);
}

- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request {
	[request setValue:twitterManager.appName forHTTPHeaderField:@"X-Twitter-Client"];
	[request setValue:twitterManager.appVersion forHTTPHeaderField:@"X-Twitter-Client-Version"];
	[request setValue:twitterManager.appWebsite forHTTPHeaderField:@"X-Twitter-Client-URL"];
}

- (BOOL) isMultiPartDataBasedOnTaskType {
	BOOL multiPartData = NO;
	switch (type) {
		case SDTwitterTaskUpdateProfileImage:
		case SDTwitterTaskUpdateProfileBackgroundImage:
			multiPartData = YES;
			break;
	}
	return multiPartData;
}

- (SDHTTPMethod) methodBasedOnTaskType {
	SDHTTPMethod method = SDHTTPMethodGet;
	switch (type) {
		case SDTwitterTaskCreateStatus:
		case SDTwitterTaskDeleteStatus:
		case SDTwitterTaskCreateDirectMessage:
		case SDTwitterTaskDeleteDirectMessage:
		case SDTwitterTaskFollowUser:
		case SDTwitterTaskUnfollowUser:
		case SDTwitterTaskUpdateDeliveryDevice:
		case SDTwitterTaskUpdateProfileColors:
		case SDTwitterTaskUpdateProfileImage:
		case SDTwitterTaskUpdateProfileBackgroundImage:
		case SDTwitterTaskUpdateProfile:
		case SDTwitterTaskFavorStatus:
		case SDTwitterTaskUnavorStatus:
		case SDTwitterTaskEnableDeviceNotificationsFromUser:
		case SDTwitterTaskDisableDeviceNotificationsFromUser:
		case SDTwitterTaskBlockUser:
		case SDTwitterTaskUnblockUser:
			method = SDHTTPMethodPost;
			break;
	}
	return method;
}

- (NSString*) URLStringBasedOnTaskType {
	NSString *URLStrings[SDTwitterTaskMAX]; // is this a bad convention? no seriously, i dont know...
	
	URLStrings[SDTwitterTaskGetPublicTimeline] = @"http://twitter.com/statuses/public_timeline.json";
	URLStrings[SDTwitterTaskGetPersonalTimeline] = @"http://twitter.com/statuses/friends_timeline.json";
	URLStrings[SDTwitterTaskGetUsersTimeline] = @"http://twitter.com/statuses/user_timeline.json";
	URLStrings[SDTwitterTaskGetMentions] = @"http://twitter.com/statuses/mentions.json";
	
	URLStrings[SDTwitterTaskGetStatus] = @"http://twitter.com/statuses/show.json";
	URLStrings[SDTwitterTaskCreateStatus] = @"http://twitter.com/statuses/update.json";
	URLStrings[SDTwitterTaskDeleteStatus] = @"http://twitter.com/statuses/destroy.json";
	
	URLStrings[SDTwitterTaskGetUserInfo] = @"http://twitter.com/users/show.json";
	URLStrings[SDTwitterTaskGetUsersFriends] = @"http://twitter.com/statuses/friends.json";
	URLStrings[SDTwitterTaskGetUsersFollowers] = @"http://twitter.com/statuses/followers.json";
	
	URLStrings[SDTwitterTaskGetReceivedDirectMessages] = @"http://twitter.com/direct_messages.json";
	URLStrings[SDTwitterTaskGetSentDirectMessages] = @"http://twitter.com/direct_messages/sent.json";
	URLStrings[SDTwitterTaskCreateDirectMessage] = @"http://twitter.com/direct_messages/new.json";
	URLStrings[SDTwitterTaskDeleteDirectMessage] = @"http://twitter.com/direct_messages/destroy.json";
	
	URLStrings[SDTwitterTaskFollowUser] = @"http://twitter.com/friendships/create.json";
	URLStrings[SDTwitterTaskUnfollowUser] = @"http://twitter.com/friendships/destroy.json";
	URLStrings[SDTwitterTaskCheckIfUserFollowsUser] = @"http://twitter.com/friendships/exists.json";
	
	URLStrings[SDTwitterTaskGetIDsOfFriends] = @"http://twitter.com/friends/ids.json";
	URLStrings[SDTwitterTaskGetIDsOfFollowers] = @"http://twitter.com/followers/ids.json";
	
	URLStrings[SDTwitterTaskVerifyCredentials] = @"http://twitter.com/account/verify_credentials.json";
	URLStrings[SDTwitterTaskUpdateDeliveryDevice] = @"http://twitter.com/account/update_delivery_device.json";
	URLStrings[SDTwitterTaskUpdateProfileColors] = @"http://twitter.com/account/update_profile_colors.json";
	URLStrings[SDTwitterTaskUpdateProfileImage] = @"http://twitter.com/account/update_profile_image.json";
	URLStrings[SDTwitterTaskUpdateProfileBackgroundImage] = @"http://twitter.com/account/update_profile_background_image.json";
	URLStrings[SDTwitterTaskUpdateProfile] = @"http://twitter.com/account/update_profile.json";
	
	URLStrings[SDTwitterTaskGetFavoriteStatuses] = @"http://twitter.com/favorites.json";
	URLStrings[SDTwitterTaskFavorStatus] = @"http://twitter.com/favorites/create.json";
	URLStrings[SDTwitterTaskUnavorStatus] = @"http://twitter.com/favorites/destroy.json";
	
	URLStrings[SDTwitterTaskEnableDeviceNotificationsFromUser] = @"http://twitter.com/notifications/follow.json";
	URLStrings[SDTwitterTaskDisableDeviceNotificationsFromUser] = @"http://twitter.com/notifications/leave.json";
	
	URLStrings[SDTwitterTaskBlockUser] = @"http://twitter.com/blocks/create.json";
	URLStrings[SDTwitterTaskUnblockUser] = @"http://twitter.com/blocks/destroy.json";
	URLStrings[SDTwitterTaskCheckIfBlockingUser] = @"http://twitter.com/blocks/exists.json";
	URLStrings[SDTwitterTaskGetBlockedUsers] = @"http://twitter.com/blocks/blocking.json";
	URLStrings[SDTwitterTaskGetBlockedUserIDs] = @"http://twitter.com/blocks/blocking/ids.json";
	
	return URLStrings[type];
}

- (void) addParametersToDictionary:(NSMutableDictionary*)parameters {
	if (count > 0)
		[parameters setObject:[NSString stringWithFormat:@"%d", (count)] forKey:@"count"];
	
	if (page > 1)
		[parameters setObject:[NSString stringWithFormat:@"%d", (page)] forKey:@"page"];
	
	if (text) {
		if (type == SDTwitterTaskCreateStatus)
			[parameters setObject:text forKey:@"status"];
		else if (type == SDTwitterTaskCreateDirectMessage)
			[parameters setObject:text forKey:@"text"];
	}
	
	if (newerThanStatusID)
		[parameters setObject:newerThanStatusID forKey:@"since_id"];
	
	if (olderThanStatusID)
		[parameters setObject:olderThanStatusID forKey:@"max_id"];
	
	if (userID)
		[parameters setObject:userID forKey:@"user_id"];
	
	if (screenName)
		[parameters setObject:screenName forKey:@"screen_name"];
	
	if (statusID)
		[parameters setObject:statusID forKey:@"id"];
	
	if (imageToUpload)
		[parameters setObject:imageToUpload forKey:@"image"];
	
	if (enableDeviceNotificationsAlso)
		[parameters setObject:@"true" forKey:@"follow"];
	
	if (firstUsersID)
		[parameters setObject:firstUsersID forKey:@"user_a"];
	
	if (secondUsersID)
		[parameters setObject:secondUsersID forKey:@"user_b"];
	
	if (profileName)
		[parameters setObject:profileName forKey:@"name"];
	
	if (profileEmail)
		[parameters setObject:profileEmail forKey:@"email"];
	
	if (profileWebsite)
		[parameters setObject:profileWebsite forKey:@"url"];
	
	if (profileLocation)
		[parameters setObject:profileLocation forKey:@"location"];
	
	if (profileDescription)
		[parameters setObject:profileDescription forKey:@"description"];
	
	if (deviceType != SDTwitterDeviceTypeNotYetSet) {
		NSString *deviceTypeString = @"none";
		if (deviceType == SDTwitterDeviceTypeInstantMessage)
			deviceTypeString = @"im";
		else if (deviceType == SDTwitterDeviceTypeSMS)
			deviceTypeString = @"sms";
		[parameters setObject:deviceTypeString forKey:@"device"];
	}
	
	if (profileBackgroundColor)
		[parameters setObject:[profileBackgroundColor hexValue] forKey:@"profile_background_color"];
	
	if (profileTextColor)
		[parameters setObject:[profileTextColor hexValue] forKey:@"profile_text_color"];
	
	if (profileLinkColor)
		[parameters setObject:[profileLinkColor hexValue] forKey:@"profile_link_color"];
	
	if (profileSidebarFillColor)
		[parameters setObject:[profileSidebarFillColor hexValue] forKey:@"profile_sidebar_fill_color"];
	
	if (profileSidebarBorderColor)
		[parameters setObject:[profileSidebarBorderColor hexValue] forKey:@"profile_sidebar_border_color"];
	
	if (shouldTileBackgroundImage)
		[parameters setObject:@"true" forKey:@"tile"];
	
	if (type == SDTwitterTaskCreateStatus)
		[parameters setObject:twitterManager.appName forKey:@"source"];
}

// MARK: -
// MARK: After-response Methods

- (void) handleHTTPResponse:(NSHTTPURLResponse*)response {
	if (response == nil)
		return;
	
	NSString *limitMaxAmount = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Limit"];
	NSString *limitRemainingAmount = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Remaining"];
	NSString *limitResetEpochTime = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Reset"];
	
	twitterManager.limitMaxAmount = [limitMaxAmount intValue];
	twitterManager.limitRemainingAmount = [limitRemainingAmount intValue];
	twitterManager.limitResetEpochDate = [limitResetEpochTime doubleValue];
}

@end

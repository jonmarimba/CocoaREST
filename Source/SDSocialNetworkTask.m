//
//  SDTwitterFetchTask.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDSocialNetworkTask.h"

#import <YAJL/YAJLDecoder.h>

#import "NSData+Base64.h"
#import "NSString+UUID.h"

#import "SDSocialNetworkManager.h"

typedef enum _SDHTTPMethod {
	SDHTTPMethodGet,
	SDHTTPMethodPost
} SDHTTPMethod;

@interface SDSocialNetworkTask (Private)

- (NSString*) _encodeString:(NSString*)string;
- (NSString*) _queryStringFromDictionary:(NSDictionary*)queryUnits;
- (NSData*) _postBodyDataFromDictionary:(NSDictionary*)dictionary;
- (void) _addAuthorizationToRequest:(NSMutableURLRequest*)request;
- (void) _setLimitValuesForManagerBasedOnResponse:(NSHTTPURLResponse*)response;
- (void) _setURLAndParametersForRequest:(NSMutableURLRequest*)request;
- (void) _appendToData:(NSMutableData*)data formatWithUTF8:(NSString*)format, ...;
- (SDHTTPMethod) _methodBasedOnTaskType;
- (NSString*) _URLStringBasedOnTaskType;

@end

@implementation SDSocialNetworkTask

@synthesize service;
@synthesize type;
@synthesize count;
@synthesize page;
@synthesize text;
@synthesize olderThanStatusID;
@synthesize newerThanStatusID;
@synthesize inReplyToStatusID;
@synthesize statusID;
@synthesize userID;
@synthesize screenName;
@synthesize imageToUpload;

@synthesize results;
@synthesize errorCode;
@synthesize error;
@synthesize taskID;

@synthesize manager;

+ (id) task {
	return [[[self alloc] init] autorelease];
}

- (NSString*) _errorString {
	NSString *errorStrings[SDSocialNetworkTaskErrorMAX];
	errorStrings[SDSocialNetworkTaskErrorInvalidType] = @"type property is invalid";
	errorStrings[SDSocialNetworkTaskErrorManagerNotSet] = @"manager property is NULL; only use -runTask: to run a task!";
	errorStrings[SDSocialNetworkTaskErrorConnectionDataIsNil] = @"Connection returned NULL data";
	errorStrings[SDSocialNetworkTaskErrorConnectionFailed] = @"Connection failed with error";
	errorStrings[SDSocialNetworkTaskErrorParserFailed] = @"Parser failed with error";
	errorStrings[SDSocialNetworkTaskErrorParserDataIsNil] = @"Parser returned NULL data";
	return errorStrings[errorCode];
}

- (id) init {
	if (self = [super init]) {
		taskID = [[NSString stringWithNewUUID] retain];
		
		service = SDSocialNetworkServiceTwitter;
		type = SDSocialNetworkTaskDoNothing;
		errorCode = SDSocialNetworkTaskErrorNone;
		
		page = 1;
		count = 0;
	}
	return self;
}

- (void) dealloc {
	[olderThanStatusID release], olderThanStatusID = nil;
	[newerThanStatusID release], newerThanStatusID = nil;
	
	[taskID release], taskID = nil;
	[results release], results = nil;
	[super dealloc];
}

- (void) main {
	if (type >= SDSocialNetworkTaskMAX || type <= SDSocialNetworkTaskDoNothing) {
		errorCode = SDSocialNetworkTaskErrorInvalidType;
		[self _sendResultsToDelegate];
		return;
	}
	if (manager == nil) {
		errorCode = SDSocialNetworkTaskErrorManagerNotSet;
		[self _sendResultsToDelegate];
		return;
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	NSError *errorFromYAJL = nil;
	
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval:30.0];
	
	[self _setURLAndParametersForRequest:request];
	
	[request setValue:manager.appName forHTTPHeaderField:@"X-Twitter-Client"];
	[request setValue:manager.appVersion forHTTPHeaderField:@"X-Twitter-Client-Version"];
	[request setValue:manager.appWebsite forHTTPHeaderField:@"X-Twitter-Client-URL"];
	
	[self _addAuthorizationToRequest:request];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
	
	// commented out the next line because some APIs are using HTTP error codes as return values, which is super lame
	
//	if (connectionError) {
//		errorCode = SDSocialNetworkTaskErrorConnectionFailed;
//		underlyingError = connectionError;
//		[self _sendResultsToDelegate];
//		return;
//	}
	
	if (data == nil) {
		errorCode = SDSocialNetworkTaskErrorConnectionDataIsNil;
		[self _sendResultsToDelegate];
		return;
	}
	
	YAJLDecoder *decoder = [[[YAJLDecoder alloc] init] autorelease];
	results = [[decoder parse:data error:&errorFromYAJL] retain];
	
	[self _setLimitValuesForManagerBasedOnResponse:response];
	
	if (errorFromYAJL) {
		errorCode = SDSocialNetworkTaskErrorParserFailed;
		underlyingError = errorFromYAJL;
	}
	else if (results == nil)
		errorCode = SDSocialNetworkTaskErrorParserDataIsNil;
	
	[self _sendResultsToDelegate];
}

// MARK: -
// MARK: Main Thread Methods (for delegation)

- (void) _sendResultsToDelegate {
	[self performSelectorOnMainThread:@selector(_sendResultsToDelegateFromMainThread) withObject:nil waitUntilDone:YES];
}

- (void) _sendResultsToDelegateFromMainThread {
	// we enter the main thread, waiting patiently til the delegate is done using us like a peice of meat
	// delegate can safely access all of our properties now
	
	if (errorCode == SDSocialNetworkTaskErrorNone) {
		[manager.delegate socialNetworkManager:manager resultsReadyForTask:self];
	}
	else {
		// we'll create our error manually and let the delegate get all touchy-feely with it all they want
		
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[self _errorString] forKey:NSLocalizedDescriptionKey];
		if (underlyingError)
			[userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
		
		// we don't retain the error object, because the pool won't drain until the delegate is done anyway
		error = [NSError errorWithDomain:@"SDSocialNetworkDomain" code:errorCode userInfo:userInfo];
		
		[manager.delegate socialNetworkManager:manager failedForTask:self];
	}
}

// MARK: -
// MARK: Before-response Methods

- (void) _setURLAndParametersForRequest:(NSMutableURLRequest*)request {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	SDHTTPMethod method = [self _methodBasedOnTaskType];
	
	NSString *URLString = [self _URLStringBasedOnTaskType];
	NSAssert(URLString != nil, @"URLString == nil; either `type` is invalid, or URL method is not complete");
	
	[self _addParametersToDictionary:parameters];
	
	switch (method) {
		case SDHTTPMethodGet: {
			NSString *queryString = [self _queryStringFromDictionary:parameters];
			[request setHTTPMethod:@"GET"];
			if ([queryString length] > 0)
				URLString = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
			break;
		}
		case SDHTTPMethodPost:
			[request setHTTPMethod:@"POST"];
			if ([self _isMultiPartDataBasedOnTaskType] == YES) {
				NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [SDSocialNetworkTask _stringBoundary]];
				[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
				
				[request setHTTPBody:[self _postBodyDataFromDictionary:parameters]];
			}
			else {
				NSString *queryString = [self _queryStringFromDictionary:parameters];
				[request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
			}
			break;
	}
	
	[request setURL:[NSURL URLWithString:URLString]];
}

- (void) _addAuthorizationToRequest:(NSMutableURLRequest*)request {
	// Set header for HTTP Basic authentication explicitly, to avoid problems with proxies and other intermediaries
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", manager.username, manager.password];
	NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
	[request setValue:authValue forHTTPHeaderField:@"Authorization"];
}

- (BOOL) _isMultiPartDataBasedOnTaskType {
	BOOL multiPartData = NO;
	switch (type) {
		case SDSocialNetworkTaskUpdateProfileImage:
		case SDSocialNetworkTaskUpdateProfileBackgroundImage:
			multiPartData = YES;
			break;
	}
	return multiPartData;
}

- (SDHTTPMethod) _methodBasedOnTaskType {
	SDHTTPMethod method = SDHTTPMethodGet;
	switch (type) {
		case SDSocialNetworkTaskCreateStatus:
		case SDSocialNetworkTaskDeleteStatus:
		case SDSocialNetworkTaskCreateDirectMessage:
		case SDSocialNetworkTaskDeleteDirectMessage:
		case SDSocialNetworkTaskFollowUser:
		case SDSocialNetworkTaskUnfollowUser:
		case SDSocialNetworkTaskUpdateDeliveryDevice:
		case SDSocialNetworkTaskUpdateProfileColors:
		case SDSocialNetworkTaskUpdateProfileImage:
		case SDSocialNetworkTaskUpdateProfileBackgroundImage:
		case SDSocialNetworkTaskUpdateProfile:
		case SDSocialNetworkTaskFavorStatus:
		case SDSocialNetworkTaskUnavorStatus:
		case SDSocialNetworkTaskEnableDeviceNotificationsFromUser:
		case SDSocialNetworkTaskDisableDeviceNotificationsFromUser:
		case SDSocialNetworkTaskBlockUser:
		case SDSocialNetworkTaskUnblockUser:
			method = SDHTTPMethodPost;
			break;
	}
	return method;
}

- (NSString*) _URLStringBasedOnTaskType {
	NSString *URLStrings[SDSocialNetworkTaskMAX]; // is this a bad convention? no seriously, i dont know...
	
	URLStrings[SDSocialNetworkTaskGetPublicTimeline] = @"http://twitter.com/statuses/public_timeline.json";
	URLStrings[SDSocialNetworkTaskGetPersonalTimeline] = @"http://twitter.com/statuses/friends_timeline.json";
	URLStrings[SDSocialNetworkTaskGetUsersTimeline] = @"http://twitter.com/statuses/user_timeline.json";
	URLStrings[SDSocialNetworkTaskGetMentions] = @"http://twitter.com/statuses/mentions.json";
	
	URLStrings[SDSocialNetworkTaskGetStatus] = @"http://twitter.com/statuses/show.json";
	URLStrings[SDSocialNetworkTaskCreateStatus] = @"http://twitter.com/statuses/update.json";
	URLStrings[SDSocialNetworkTaskDeleteStatus] = @"http://twitter.com/statuses/destroy.json";
	
	URLStrings[SDSocialNetworkTaskGetUserInfo] = @"http://twitter.com/users/show.json";
	URLStrings[SDSocialNetworkTaskGetUsersFriends] = @"http://twitter.com/statuses/friends.json";
	URLStrings[SDSocialNetworkTaskGetUsersFollowers] = @"http://twitter.com/statuses/followers.json";
	
	URLStrings[SDSocialNetworkTaskGetReceivedDirectMessages] = @"http://twitter.com/direct_messages.json";
	URLStrings[SDSocialNetworkTaskGetSentDirectMessages] = @"http://twitter.com/direct_messages/sent.json";
	URLStrings[SDSocialNetworkTaskCreateDirectMessage] = @"http://twitter.com/direct_messages/new.json";
	URLStrings[SDSocialNetworkTaskDeleteDirectMessage] = @"http://twitter.com/direct_messages/destroy.json";
	
	URLStrings[SDSocialNetworkTaskFollowUser] = @"http://twitter.com/friendships/create.json";
	URLStrings[SDSocialNetworkTaskUnfollowUser] = @"http://twitter.com/friendships/destroy.json";
	URLStrings[SDSocialNetworkTaskCheckIfUserFollowsUser] = @"http://twitter.com/friendships/exists.json";
	
	URLStrings[SDSocialNetworkTaskGetIDsOfFriends] = @"http://twitter.com/friends/ids.json";
	URLStrings[SDSocialNetworkTaskGetIDsOfFollowers] = @"http://twitter.com/followers/ids.json";
	
	URLStrings[SDSocialNetworkTaskVerifyCredentials] = @"http://twitter.com/account/verify_credentials.json";
	URLStrings[SDSocialNetworkTaskUpdateDeliveryDevice] = @"http://twitter.com/account/update_delivery_device.json";
	URLStrings[SDSocialNetworkTaskUpdateProfileColors] = @"http://twitter.com/account/update_profile_colors.json";
	URLStrings[SDSocialNetworkTaskUpdateProfileImage] = @"http://twitter.com/account/update_profile_image.json";
	URLStrings[SDSocialNetworkTaskUpdateProfileBackgroundImage] = @"http://twitter.com/account/update_profile_background_image.json";
	URLStrings[SDSocialNetworkTaskUpdateProfile] = @"http://twitter.com/account/update_profile.json";
	
	URLStrings[SDSocialNetworkTaskGetFavoriteStatuses] = @"http://twitter.com/favorites.json";
	URLStrings[SDSocialNetworkTaskFavorStatus] = @"http://twitter.com/favorites/create.json";
	URLStrings[SDSocialNetworkTaskUnavorStatus] = @"http://twitter.com/favorites/destroy.json";
	
	URLStrings[SDSocialNetworkTaskEnableDeviceNotificationsFromUser] = @"http://twitter.com/notifications/follow.json";
	URLStrings[SDSocialNetworkTaskDisableDeviceNotificationsFromUser] = @"http://twitter.com/notifications/leave.json";
	
	URLStrings[SDSocialNetworkTaskBlockUser] = @"http://twitter.com/blocks/create.json";
	URLStrings[SDSocialNetworkTaskUnblockUser] = @"http://twitter.com/blocks/destroy.json";
	URLStrings[SDSocialNetworkTaskCheckIfBlockingUser] = @"http://twitter.com/blocks/exists.json";
	URLStrings[SDSocialNetworkTaskGetBlockedUsers] = @"http://twitter.com/blocks/blocking.json";
	URLStrings[SDSocialNetworkTaskGetBlockedUserIDs] = @"http://twitter.com/blocks/blocking/ids.json";
	
	return URLStrings[type];
}

- (void) _addParametersToDictionary:(NSMutableDictionary*)parameters {
	if (count > 0)
		[parameters setObject:[NSString stringWithFormat:@"%d", (count)] forKey:@"count"];
	
	if (page > 1)
		[parameters setObject:[NSString stringWithFormat:@"%d", (page)] forKey:@"page"];
	
	if (text) {
		if (type == SDSocialNetworkTaskCreateStatus)
			[parameters setObject:text forKey:@"status"];
		else if (type == SDSocialNetworkTaskCreateDirectMessage)
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
	
	if (type == SDSocialNetworkTaskCreateStatus)
		[parameters setObject:manager.appName forKey:@"source"];
}

- (void) _setURLAndParametersForRequest:(NSMutableURLRequest*)request {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	SDHTTPMethod method = [self _methodBasedOnTaskType];
	NSString *URLString = [self _URLStringBasedOnTaskType];
	
	[self _addParametersToDictionary:parameters];
	
	BOOL multiPartData = NO;
	switch (type) {
		case SDSocialNetworkTaskUpdateProfileImage:
		case SDSocialNetworkTaskUpdateProfileBackgroundImage:
			multiPartData = YES;
			break;
	}
	
	switch (method) {
		case SDHTTPMethodGet: {
			NSString *queryString = [self _queryStringFromDictionary:parameters];
			[request setHTTPMethod:@"GET"];
			if ([queryString length] > 0)
				URLString = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
			break;
		}
		case SDHTTPMethodPost:
			[request setHTTPMethod:@"POST"];
			if (multiPartData == YES) {
				NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [SDSocialNetworkTask stringBoundary]];
				[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
				
				[request setHTTPBody:[self _postBodyDataFromDictionary:parameters]];
			}
			else {
				NSString *queryString = [self _queryStringFromDictionary:parameters];
				[request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
			}
			break;
	}
	
	[request setURL:[NSURL URLWithString:URLString]];
}

- (void) _addAuthorizationToRequest:(NSMutableURLRequest*)request {
	// Set header for HTTP Basic authentication explicitly, to avoid problems with proxies and other intermediaries
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", manager.username, manager.password];
	NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
	[request setValue:authValue forHTTPHeaderField:@"Authorization"];
}

// MARK: -
// MARK: After-response Methods

- (void) _setLimitValuesForManagerBasedOnResponse:(NSHTTPURLResponse*)response {
	if (response == nil)
		return;
	
	NSString *limitMaxAmount = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Limit"];
	NSString *limitRemainingAmount = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Remaining"];
	NSString *limitResetEpochTime = [[response allHeaderFields] objectForKey:@"X-Ratelimit-Reset"];
	
	manager.limitMaxAmount = [limitMaxAmount intValue];
	manager.limitRemainingAmount = [limitRemainingAmount intValue];
	manager.limitResetEpochDate = [limitResetEpochTime doubleValue];
}

// MARK: -
// MARK: General Helper Methods

- (NSString*) _queryStringFromDictionary:(NSDictionary*)queryUnits {
	NSMutableArray *queryParts = [NSMutableArray array];
	for (NSString *key in queryUnits) {
		NSString *object = [queryUnits objectForKey:key];
		
		NSString *queryPart = [NSString stringWithFormat:@"%@=%@", key, [self _encodeString:object]];
		[queryParts addObject:queryPart];
	}
	
	return [queryParts componentsJoinedByString:@"&"];
}

- (NSString*) _encodeString:(NSString*)string {
	// stolen from Matt Gemmell (though he probably stole it from elsewhere, so it should be okay)
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)string,
																		   NULL,
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}

@end

//
//  SDFacebookTask.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 6/7/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDFacebookTask.h"

#import "SDFacebookTaskManager.h"

#import "SDNetTask+Subclassing.h"

#import <openssl/md5.h>

@interface SDFacebookTask (Private)

- (NSString*) signatureFromArguments:(NSDictionary*)args;
- (NSString*) apiMethodBasedOnTaskType;

@end


@implementation SDFacebookTask

@synthesize UIDs;

@synthesize noteID;
@synthesize title;
@synthesize content;

@synthesize appPermissionType;

- (id) initWithManager:(SDFacebookTaskManager*)newManager {
	if (self = [super initWithManager:newManager]) {
		facebookManager = newManager;
		
		type = SDFacebookTaskDoNothing;
		errorCode = SDNetTaskErrorNone;
		
//		page = 1;
//		count = 0;
	}
	return self;
}

- (void) dealloc {
	[UIDs release], UIDs = nil;
	
	[noteID release], noteID = nil;
	[title release], title = nil;
	[content release], content = nil;
	
	[appPermissionType release], appPermissionType = nil;
	
	[super dealloc];
}

- (void) run {
	if (type == SDFacebookTaskGetAllowAppPermissionsURL) {
		NSString *URLString = [NSString stringWithFormat:@"http://www.facebook.com/authorize.php?api_key=%@&v=%@&ext_perm=%@&popup&skipcookie",
							   facebookManager.apiKey,
							   facebookManager.apiVersion,
							   self.appPermissionType];
		
		results = [URLString retain];
		[self sendResultsToDelegate];
		
		return;
	}
	
	[super run];
}

- (id) copyWithZone:(NSZone*)zone {
	SDFacebookTask *copy = [super copyWithZone:zone];
	
	copy.UIDs = self.UIDs;
	
	copy.noteID = self.noteID;
	copy.title = self.title;
	copy.content = self.content;
	
	copy.appPermissionType = self.appPermissionType;

	return copy;
}

- (BOOL) validateType {
	return (type > SDFacebookTaskDoNothing && type < SDFacebookTaskMAX);
}

- (BOOL) shouldUseBasicHTTPAuthentication {
	return NO;
}

- (void) handleHTTPResponse:(NSHTTPURLResponse*)response {
}

- (BOOL) isMultiPartDataBasedOnTaskType {
	return NO;
}

- (SDHTTPMethod) methodBasedOnTaskType {
	switch (type) {
		case SDFacebookTaskEditNote:
			return SDHTTPMethodPost;
		default:
			return SDHTTPMethodGet;
	}
}

- (NSString*) URLStringBasedOnTaskType {
	return @"https://api.facebook.com/restserver.php";
}

- (SDParseFormat) parseFormatBasedOnTaskType {
	switch (type) {
		case SDFacebookTaskGetAppPermissions:
		case SDFacebookTaskGetLoginURL:
			return SDParseFormatNone;
	}
	return SDParseFormatJSON;
}

- (NSString*) apiMethodBasedOnTaskType {
	NSString *methods[SDFacebookTaskMAX] = {@""};
	
	methods[SDFacebookTaskGetLoginURL] = @"Auth.createToken";
	methods[SDFacebookTaskFinishLoginProcess] = @"Auth.getSession";
	methods[SDFacebookTaskGetUserInfo] = @"Users.getInfo";
	methods[SDFacebookTaskGetFriends] = @"Friends.get";
	methods[SDFacebookTaskGetNotes] = @"Notes.get";
	methods[SDFacebookTaskEditNote] = @"Notes.edit";
	methods[SDFacebookTaskGetAppPermissions] = @"Users.hasAppPermission";
	
	return methods[type];
}

- (void) addParametersToDictionary:(NSMutableDictionary*)parameters {
	[parameters setObject:[self apiMethodBasedOnTaskType] forKey:@"method"];
	[parameters setObject:@"JSON" forKey:@"format"];
	
	[parameters setObject:facebookManager.apiVersion forKey:@"v"];
	[parameters setObject:facebookManager.apiKey forKey:@"api_key"];
	
	if (type != SDFacebookTaskGetLoginURL && facebookManager.authToken)
		[parameters setObject:facebookManager.authToken forKey:@"auth_token"];
	
	if (type > SDFacebookTaskFinishLoginProcess)
		[parameters setObject:facebookManager.sessionKey forKey:@"session_key"];
	
	if (noteID)
		[parameters setObject:noteID forKey:@"note_id"];
	
	if (title)
		[parameters setObject:title forKey:@"title"];
	
	if (content)
		[parameters setObject:content forKey:@"content"];
	
	if (appPermissionType)
		[parameters setObject:appPermissionType forKey:@"ext_perm"];
	
	
	if (UIDs)
		[parameters setObject:[UIDs componentsJoinedByString:@","] forKey:@"uids"];
	
	// temp (horrible)
	if (UIDs)
		[parameters setObject:@"name" forKey:@"fields"];
	
	// add signature
	[parameters setObject:[self signatureFromArguments:parameters] forKey:@"sig"];
}

- (void) sendResultsToDelegate {
	if ([results isKindOfClass:[NSDictionary class]] && [[results allKeys] containsObject:@"error_code"]) {
		error = [NSError errorWithDomain:@"SDNetDomain" code:SDNetTaskErrorServiceDefinedError userInfo:nil];
		[self sendErrorToDelegate];
		return;
	}
	
	if (type == SDFacebookTaskGetLoginURL) {
		NSString *authToken = self.results;
		
		NSRange range = NSMakeRange(1, [authToken length] - 2);
		facebookManager.authToken = [authToken substringWithRange:range];
		
		NSString *baseURLString = @"http://www.facebook.com/login.php?v=1.0&skipcookie=1&popup=1&api_key=%@&auth_token=%@";
		NSString *URLString = [NSString stringWithFormat:baseURLString, facebookManager.apiKey, facebookManager.authToken];
		
		[results autorelease];
		results = [URLString retain];
	}
	else if (type == SDFacebookTaskFinishLoginProcess) {
		facebookManager.sessionSecret = [self.results objectForKey:@"secret"];
		facebookManager.sessionKey = [self.results objectForKey:@"session_key"];
		
		NSNumber *sessionUID = [self.results objectForKey:@"uid"];
		facebookManager.sessionUID = [NSString stringWithFormat:@"%lld", [sessionUID longLongValue]];
		
		NSNumber *expires = [self.results objectForKey:@"expires"];
		NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:[expires doubleValue]];
		
		NSMutableDictionary *newResults = [NSMutableDictionary dictionary];
		[newResults setObject:facebookManager.sessionUID forKey:@"sessionIdentifier"];
		[newResults setObject:[facebookManager sessionCredentials] forKey:@"sessionCredentials"];
		if ([expires isEqualToNumber:[NSNumber numberWithInt:0]])
			[newResults setObject:expirationDate forKey:@"sessionExpirationDate"];
		
		[results autorelease];
		results = [newResults retain];
	}
	
	[super sendResultsToDelegate];
}

- (void) sendErrorToDelegate {
	[super sendErrorToDelegate];
}

// MARK: -
// MARK: FB Helper Methods

- (NSString*) signatureFromArguments:(NSDictionary*)args {
	// add args into array
	NSMutableArray *sigArray = [NSMutableArray array];
	for (NSString *key in args)
		[sigArray addObject:[NSString stringWithFormat:@"%@=%@", key, [args objectForKey:key]]];
	
	// sort by alphabet
	[sigArray sortUsingSelector:@selector(compare:)];
	
	// add secret key
	if (type > SDFacebookTaskFinishLoginProcess)
		[sigArray addObject:facebookManager.sessionSecret];
	else
		[sigArray addObject:facebookManager.apiSecret];
	
	// altogether now!
	NSString *sigStr = [sigArray componentsJoinedByString:@""];
	
	// get its hash in hex form
	NSData *data = [sigStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
	unsigned char digest[16];
	char finaldigest[32];
	MD5([data bytes], [data length], digest);
	for (int i = 0; i < 16; i++)
		sprintf(finaldigest + (i * 2), "%02x", digest[i]);
	
	// return it as an NSString
	return [NSString stringWithCString:finaldigest length:32];
}

@end

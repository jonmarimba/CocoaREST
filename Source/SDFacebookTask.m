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
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*)zone {
	id copy = [super copyWithZone:zone];
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
	return SDHTTPMethodGet;
}

- (NSString*) URLStringBasedOnTaskType {
	return @"https://api.facebook.com/restserver.php";
}

- (SDParseFormat) parseFormatBasedOnTaskType {
	switch (type) {
		case SDFacebookTaskGetLoginURL:
			return SDParseFormatNone;
	}
	return SDParseFormatJSON;
}

- (NSString*) apiMethodBasedOnTaskType {
	switch (type) {
		case SDFacebookTaskGetLoginURL:
			return @"Auth.createToken";
		case SDFacebookTaskFinishLoginProcess:
			return @"Auth.getSession";
		case SDFacebookTaskGetUserInfo:
			return @"Users.getInfo";
		case SDFacebookTaskGetFriends:
			return @"Friends.get";
	}
	return nil;
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
	
	if (UIDs)
		[parameters setObject:[UIDs componentsJoinedByString:@","] forKey:@"uids"];
	
	// temp (horrible)
	if (UIDs)
		[parameters setObject:@"name" forKey:@"fields"];
	
	// add signature
	[parameters setObject:[self signatureFromArguments:parameters] forKey:@"sig"];
}

- (void) sendResultsToDelegate {
	if (type == SDFacebookTaskGetLoginURL) {
		NSString *authToken = self.results;
		
		NSRange range = NSMakeRange(1, [authToken length] - 2);
		facebookManager.authToken = [authToken substringWithRange:range];
		
		NSString *baseURLString = @"http://www.facebook.com/login.php?v=1.0&skipcookie=1&popup=1&api_key=%@&auth_token=%@";
		NSString *URLString = NSSTRINGF(baseURLString, facebookManager.apiKey, facebookManager.authToken);
		
		[results autorelease];
		results = [URLString retain];
		
		[super sendResultsToDelegate];
	}
	else if (type == SDFacebookTaskFinishLoginProcess) {
		facebookManager.sessionSecret = [self.results objectForKey:@"secret"];
		facebookManager.sessionKey = [self.results objectForKey:@"session_key"];
		
		NSNumber *sessionUID = [self.results objectForKey:@"uid"];
		facebookManager.sessionUID = [NSString stringWithFormat:@"%lld", [sessionUID longLongValue]];
		
		BOOL success = YES;
		
		[results autorelease];
		results = [[NSNumber numberWithBool:success] retain];;
		
		[super sendResultsToDelegate];
	}
	else {
		[super sendResultsToDelegate];
	}
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

//
//  SDFacebookManager.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 6/7/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTaskManager.h"
#import "SDFacebookTask.h"

@interface SDFacebookTaskManager : SDNetTaskManager {
	NSString *apiKey;
	NSString *apiSecret;
	NSString *apiVersion;
	
	NSString *authToken;
	
	NSString *sessionSecret;
	NSString *sessionKey;
	NSString *sessionUID;
}

@property (copy) NSString *apiKey;
@property (copy) NSString *apiSecret;
@property (copy) NSString *apiVersion;

// only SDFacebookTask uses these, generally
@property (copy) NSString *authToken;

@property (copy) NSString *sessionSecret;
@property (copy) NSString *sessionKey;
@property (copy) NSString *sessionUID;

- (void) useSessionIdentifier:(NSString*)sessionIdentifier sessionCredentials:(NSString*)sessionCredentials;

- (NSString*) sessionCredentials;

@end

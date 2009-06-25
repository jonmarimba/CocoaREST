//
//  SDFacebookManager.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 6/7/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDFacebookTaskManager.h"


@implementation SDFacebookTaskManager

@synthesize apiKey;
@synthesize apiSecret;
@synthesize apiVersion;

@synthesize authToken;

@synthesize sessionSecret;
@synthesize sessionKey;
@synthesize sessionUID;

- (void) dealloc {
	[apiKey release], apiKey = nil;
	[apiSecret release], apiSecret = nil;
	[apiVersion release], apiVersion = nil;
	
	[authToken release], authToken = nil;
	[sessionSecret release], sessionSecret = nil;
	[sessionKey release], sessionKey = nil;
	[sessionUID release], sessionUID = nil;
	
	[super dealloc];
}

@end

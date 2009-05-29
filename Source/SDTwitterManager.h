//
//  SDTwitterManager.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkManager.h"

@class SDTwitterTask;

@interface SDTwitterManager : SDSocialNetworkManager {
	NSString *appName;
	NSString *appVersion;
	NSString *appWebsite;
	
	int limitMaxAmount;
	int limitRemainingAmount;
	NSTimeInterval limitResetEpochDate;
}

@property (copy) NSString *appName;
@property (copy) NSString *appVersion;
@property (copy) NSString *appWebsite;

// the following properties are set during every task
// while they are read-write, don't set them; it defeats the point.

@property int limitMaxAmount;
@property int limitRemainingAmount;
@property NSTimeInterval limitResetEpochDate;

@end

@protocol SDTwitterTaskDelegate

@required

- (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task;
- (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task;

@end

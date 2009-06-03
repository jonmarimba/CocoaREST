//
//  SDTwitterManager.h
//  SDNet
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTaskManager.h"

#import "SDTwitterTask.h"
#import "SDTwitterTaskDelegate.h"

@interface SDTwitterManager : SDNetTaskManager {
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

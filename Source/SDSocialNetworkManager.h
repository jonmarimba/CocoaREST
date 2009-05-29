//
//  SDTwitterEngine.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkTaskDelegateProtocol.h"

@class SDSocialNetworkTask;

@interface SDSocialNetworkManager : NSObject {
	NSOperationQueue *queue;
	
	id <SDSocialNetworkTaskDelegate, NSObject> delegate;
	
	NSString *username;
	NSString *password;
	
	NSString *appName;
	NSString *appVersion;
	NSString *appWebsite;
	
	int limitMaxAmount;
	int limitRemainingAmount;
	NSTimeInterval limitResetEpochDate;
}

// set these properties

@property (assign) id <SDSocialNetworkTaskDelegate, NSObject> delegate;

@property (copy) NSString *username;
@property (copy) NSString *password;

@property (copy) NSString *appName;
@property (copy) NSString *appVersion;
@property (copy) NSString *appWebsite;

@property NSInteger maxConcurrentTasks;

// the following properties are set during every task
// while they are read-write, don't set them; it defeats the point.

@property int limitMaxAmount;
@property int limitRemainingAmount;
@property NSTimeInterval limitResetEpochDate;

+ (id) manager; // convenience method
- (id) init; // designated initializer

- (void) runTask:(SDSocialNetworkTask*)taskToRun;

- (void) cancelAllTasks;
- (void) cancelTask:(SDSocialNetworkTask*)taskToCancel;

- (void) setMaxConcurrentTasks:(int)count;
- (void) setMaxConcurrentTasks:(int)count;

@end

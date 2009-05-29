//
//  SDTwitterEngine.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDSocialNetworkManager.h"

@implementation SDSocialNetworkManager

@synthesize delegate;

@synthesize username;
@synthesize password;

@dynamic maxConcurrentTasks;

+ (id) manager {
	return [[[self alloc] init] autorelease];
}

- (id) init {
	if (self = [super init]) {
		queue = [[NSOperationQueue alloc] init];
		
		// let's default to generosity until a good reason not to shows up
		[queue setMaxConcurrentOperationCount:12];
	}
	return self;
}

- (void) dealloc {
	[self cancelAllTasks];
	
	[username release], username = nil;
	[password release], password = nil;
	
	[queue release], queue = nil;
	[super dealloc];
}

- (void) cancelAllTasks {
	for (SDSocialNetworkTask *taskToCancel in [queue operations])
		[self cancelTask:taskToCancel];
}

- (void) cancelTask:(SDSocialNetworkTask*)taskToCancel {
	// we let the task run its course, but since it uses .manager for
	// most of its work, and for its delegation, it will do nothing
	
	[taskToCancel cancel];
}

- (void) runTask:(SDSocialNetworkTask*)taskToRun {
	[queue addOperation:taskToRun];
}

- (void) setMaxConcurrentTasks:(NSInteger)count {
	[queue setMaxConcurrentOperationCount:count];
}

- (NSInteger) maxConcurrentTasks {
	return [queue maxConcurrentOperationCount];
}

@end

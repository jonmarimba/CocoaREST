//
//  AppDelegate.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void) awakeFromNib {
	// inside a header file, declare manager as an instance variable
	SDIdenticaManager *manager;
	
	// create out manager, retaining it as we want it to stick around
	manager = [[SDIdenticaManager manager] retain];
	manager.delegate = self;
	
	// this is a must for certain API calls which require authentication
	// change them to real login values or the tasks will fail
	manager.username = @"USERNAME";
	manager.password = @"PASSWORD";
	
	// 3 tasks can be run simultaneously
	manager.maxConcurrentTasks = 3;
	
	// create a basic task
	SDIdenticaTask *mentionsTask = [SDIdenticaTask taskWithManager:manager];
	mentionsTask.type = SDIdenticaTaskGetPublicTimeline;
	[mentionsTask run];
}

- (void) identicaManager:(SDIdenticaManager*)manager resultsReadyForTask:(SDIdenticaTask*)task {
	NSLog(@"%@", task.results);
}

- (void) identicaManager:(SDIdenticaManager*)manager failedForTask:(SDIdenticaTask*)task {
	NSLog(@"%@", task.error);
}

@end

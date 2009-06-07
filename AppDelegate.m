//
//  AppDelegate.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "AppDelegate.h"

#import "SDTwitterManager.h"

@implementation AppDelegate

- (void) awakeFromNib {
	// inside a header file, declare manager as an instance variable
	SDTwitterManager *manager;
	
	// create out manager, retaining it as we want it to stick around
	manager = [[SDTwitterManager manager] retain];
	manager.successSelector = @selector(twitterManager:resultsReadyForTask:);
	manager.failSelector = @selector(twitterManager:failedForTask:);
	manager.delegate = self;
	
	// this is a must for certain API calls which require authentication
	// change them to real login values or the tasks will fail
	manager.username = @"USERNAME";
	manager.password = @"PASSWORD";
	
	// 3 tasks can be run simultaneously
	manager.maxConcurrentTasks = 3;
	
	// create a basic task
	SDTwitterTask *mentionsTask = [SDTwitterTask taskWithManager:manager];
	mentionsTask.type = SDTwitterTaskGetPersonalTimeline;
	mentionsTask.count = 3;
	mentionsTask.page = 10;
	[mentionsTask run];
}

- (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task {
	NSLog(@"%@", task.results);
}

- (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task {
	NSLog(@"%@", task.error);
}

@end

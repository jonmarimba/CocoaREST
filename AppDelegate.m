//
//  AppDelegate.m
//  SDNet
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "AppDelegate.h"

#import "SDTwitterTaskManager.h"

@implementation AppDelegate

- (void) awakeFromNib {
	// inside a header file, declare manager as an instance variable
	SDTwitterTaskManager *manager;
	
	// create out manager, retaining it as we want it to stick around
	manager = [[SDTwitterTaskManager manager] retain];
	manager.delegate = self;
	manager.successSelector = @selector(twitterManager:resultsReadyForTask:);
	manager.failSelector = @selector(twitterManager:failedForTask:);
	
	// this is a must for certain API calls which require authentication
	// change them to real login values or the tasks will fail
	manager.username = @"USERNAME";
	manager.password = @"PASSWORD";
	
	// 3 tasks can be run simultaneously
	manager.maxConcurrentTasks = 3;
	
	// create a basic task
	SDTwitterTask *basicTask = [SDTwitterTask taskWithManager:manager];
	basicTask.type = SDTwitterTaskGetMentions;
	basicTask.count = 3;
	basicTask.page = 10;
	[basicTask run];
}

- (void) twitterManager:(SDTwitterTaskManager*)manager resultsReadyForTask:(SDTwitterTask*)task {
	NSLog(@"%@", task.results);
}

- (void) twitterManager:(SDTwitterTaskManager*)manager failedForTask:(SDTwitterTask*)task {
	NSLog(@"%@", task.error);
}

@end

//
//  AppDelegate.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "AppDelegate.h"

#import "SDTwitterTask.h"

@implementation AppDelegate

- (void) awakeFromNib {
	// inside a header file, declare manager as an instance variable
	SDTwitterManager *manager;
	
	// create out manager, retaining it as we want it to stick around
	manager = [[SDTwitterManager manager] retain];
	manager.delegate = self;
	
	// change this info to match your app
	manager.appName = @"My Great App";
	manager.appVersion = @"7.0";
	manager.appWebsite = @"http://www.googlw.com/";
	
	// this is a must for certain API calls which require authentication
	// change them to real login values or the tasks will fail
	manager.username = @"USERNAME";
	manager.password = @"PASSWORD";
	
	// 3 tasks can be run simultaneously
	manager.maxConcurrentTasks = 3;
	
	// create a basic task
	SDTwitterTask *mentionsTask = [SDTwitterTask taskWithManager:manager];
	mentionsTask.type = SDTwitterTaskGetMentions;
	mentionsTask.count = 4;
	mentionsTask.page = 2;
	[mentionsTask run];
	
	// post a simple message on twitter
	SDTwitterTask *updateTask = [SDTwitterTask taskWithManager:manager];
	updateTask.type = SDTwitterTaskCreateStatus;
	updateTask.text = @"Experimenting with the brand new SDSocialNetwork library for Cocoa!";
	[updateTask run];
}

- (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task {
	NSLog(@"%@", task.results);
}

- (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task {
	NSLog(@"%@", task.error);
}

@end

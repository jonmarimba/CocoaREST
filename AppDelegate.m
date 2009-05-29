//
//  AppDelegate.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "AppDelegate.h"

#import "SDSocialNetworkTask.h"

@implementation AppDelegate

- (void) awakeFromNib {
	// inside a header file, declare manager as an instance variable
	SDSocialNetworkManager *manager;
	
	// create out manager, retaining it as we want it to stick around
	manager = [[SDSocialNetworkManager manager] retain];
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
	SDSocialNetworkTask *mentionsTask = [SDSocialNetworkTask task];
	mentionsTask.type = SDSocialNetworkTaskGetMentions;
	mentionsTask.count = 4;
	mentionsTask.page = 2;
	[manager runTask:mentionsTask];
	
	// post a simple message on twitter
	SDSocialNetworkTask *updateTask = [SDSocialNetworkTask task];
	updateTask.type = SDSocialNetworkTaskCreateStatus;
	updateTask.text = @"Experimenting with the brand new SDSocialNetwork library for Cocoa!";
	[manager runTask:updateTask];
}

- (void) socialNetworkManager:(SDSocialNetworkManager*)manager resultsReadyForTask:(SDSocialNetworkTask*)task {
	NSLog(@"%@", task.results);
}

- (void) socialNetworkManager:(SDSocialNetworkManager*)manager failedForTask:(SDSocialNetworkTask*)task {
	NSLog(@"%@", task.error);
}

@end

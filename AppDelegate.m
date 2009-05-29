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
	socialNetworkManager = [[SDSocialNetworkManager manager] retain];
	socialNetworkManager.delegate = self;
	
	socialNetworkManager.appName = @"My Great App";
	socialNetworkManager.appVersion = @"7.0";
	socialNetworkManager.appWebsite = @"http://www.googlw.com/";
	
	socialNetworkManager.username = @"USERNAME";
	socialNetworkManager.password = @"PASSWORD";
	
	socialNetworkManager.maxConcurrentTasks = 1;
	
	// test tasks go here
	
	SDSocialNetworkTask *task = [SDSocialNetworkTask task];
	
	task.type = SDSocialNetworkTaskVerifyCredentials;
	
//	task.type = SDSocialNetworkTaskGetUserInfo;
//	task.screenName = @"frumpa";
	
//	task.type = SDSocialNetworkTaskDeleteStatus;
//	task.statusID = @"1415307804";
	
//	task.type = SDSocialNetworkTaskCreateStatus;
//	task.text = @"oh golly, i wonder what this will say for client";
	
	[socialNetworkManager runTask:task];
}

- (void) socialNetworkManager:(SDSocialNetworkManager*)manager resultsReadyForTask:(SDSocialNetworkTask*)task {
	NSLog(@"%@", task.results);
}

@end

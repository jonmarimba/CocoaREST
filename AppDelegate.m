//
//  AppDelegate.m
//  SDNet
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize isWaiting;
@synthesize results;

- (void) applicationDidFinishLaunching:(NSNotification*)notification {
	manager = [[SDTwitterTaskManager manager] retain];
	manager.delegate = self;
	manager.successSelector = @selector(twitterManager:resultsReadyForTask:);
	manager.failSelector = @selector(twitterManager:failedForTask:);
	manager.maxConcurrentTasks = 3;
}

- (IBAction) runTask:(id)sender {
	manager.username = [userField stringValue];
	manager.password = [passField stringValue];
	
	SDTwitterTask *basicTask = [SDTwitterTask taskWithManager:manager];
	basicTask.type = [[taskTypeButton selectedItem] tag];
	[basicTask run];
	
	self.isWaiting = YES;
}

- (void) twitterManager:(SDTwitterTaskManager*)manager resultsReadyForTask:(SDTwitterTask*)task {
	self.isWaiting = NO;
	
	self.results = task.results;
}

- (void) twitterManager:(SDTwitterTaskManager*)manager failedForTask:(SDTwitterTask*)task {
	self.isWaiting = NO;
	
	self.results = nil;
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Error"];
	[alert setInformativeText:[task.error localizedDescription]];
	[alert runModal];
}

@end

//
//  SDTwitterEngine.h
//  SDNet
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTask.h"

@interface SDNetTaskManager : NSObject {
	NSOperationQueue *queue;
	
	id <NSObject> delegate;
	SEL successSelector;
	SEL failSelector;
	
	NSString *username;
	NSString *password;
}

// set these properties

@property (assign) id <NSObject> delegate;

// both of the following selectors need to return (void) and have two
// arguments, SDNetManager and SDNetTask, in that order. for example:

// - (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task;
// - (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task;

@property SEL successSelector;
@property SEL failSelector;

@property (copy) NSString *username;
@property (copy) NSString *password;

@property NSInteger maxConcurrentTasks;

+ (id) manager; // designated convenience initializer
- (id) init; // designated initializer

- (void) runTask:(SDNetTask*)taskToRun;

- (void) cancelAllTasks;
- (void) cancelTask:(SDNetTask*)taskToCancel;

@end

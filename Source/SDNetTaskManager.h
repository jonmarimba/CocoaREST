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
	
	NSString *username;
	NSString *password;
}

// set these properties

@property (assign) id <NSObject> delegate;

@property (copy) NSString *username;
@property (copy) NSString *password;

@property NSInteger maxConcurrentTasks;

+ (id) manager; // designated convenience initializer
- (id) init; // designated initializer

- (void) runTask:(SDNetTask*)taskToRun;

- (void) cancelAllTasks;
- (void) cancelTask:(SDNetTask*)taskToCancel;

@end

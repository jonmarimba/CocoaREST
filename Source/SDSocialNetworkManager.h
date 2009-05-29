//
//  SDTwitterEngine.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkTask.h"

@interface SDSocialNetworkManager : NSObject {
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

- (void) runTask:(SDSocialNetworkTask*)taskToRun;

- (void) cancelAllTasks;
- (void) cancelTask:(SDSocialNetworkTask*)taskToCancel;

@end

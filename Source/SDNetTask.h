//
//  SDTwitterFetchTask.h
//  SDNet
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDNetTaskManager;

typedef enum _SDNetTaskError {
	SDNetTaskErrorNone,
	SDNetTaskErrorInvalidType,
	SDNetTaskErrorManagerNotSet,
	SDNetTaskErrorConnectionDataIsNil,
	SDNetTaskErrorConnectionFailed,
	SDNetTaskErrorParserFailed,
	SDNetTaskErrorParserDataIsNil,
	SDNetTaskErrorServiceDefinedError,
	
	SDNetTaskErrorMAX // once again, don't touch.
} SDNetTaskError;

@interface SDNetTask : NSOperation <NSCopying> {
	SDNetTaskManager *manager;
	
	int type;
	void* context;
	
	NSString *taskID;
	id results;
	
	SDNetTaskError errorCode;
	NSError *error;
	NSError *underlyingError;
}

// designated convenience initializer

+ (id) taskWithManager:(SDNetTaskManager*)newManager;
- (id) initWithManager:(SDNetTaskManager*)newManager;

- (void) run;
- (void) cancel;

// readable properties: use after task is complete

@property int type;

@property void* context;

@property (readonly) id results;

@property (readonly) SDNetTaskError errorCode;
@property (readonly) NSError *error;

@property (readonly) NSString *taskID; // DEPRECATED; do not use unless you REALLY want to.

@end

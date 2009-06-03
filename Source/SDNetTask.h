//
//  SDTwitterFetchTask.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDNetTaskManager;

typedef enum _SDSocialNetworkTaskError {
	SDSocialNetworkTaskErrorNone,
	SDSocialNetworkTaskErrorInvalidType,
	SDSocialNetworkTaskErrorManagerNotSet,
	SDSocialNetworkTaskErrorConnectionDataIsNil,
	SDSocialNetworkTaskErrorConnectionFailed,
	SDSocialNetworkTaskErrorParserFailed,
	SDSocialNetworkTaskErrorParserDataIsNil,
	
	SDSocialNetworkTaskErrorMAX // once again, don't touch.
} SDSocialNetworkTaskError;

@interface SDNetTask : NSOperation <NSCopying> {
	SDNetTaskManager *manager;
	
	int type;
	
	NSString *taskID;
	id results;
	
	SDSocialNetworkTaskError errorCode;
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

@property (readonly) id results;

@property (readonly) SDSocialNetworkTaskError errorCode;
@property (readonly) NSError *error;

@property (readonly) NSString *taskID; // DEPRECATED; do not use unless you REALLY want to.

@end

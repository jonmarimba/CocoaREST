//
//  SDTwitterManager.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDFriendfeedManager;
@class SDFriendfeedTask;

@protocol SDFriendfeedTaskDelegate

@required

- (void) friendfeedManager:(SDFriendfeedManager*)manager resultsReadyForTask:(SDFriendfeedTask*)task;
- (void) friendfeedManager:(SDFriendfeedManager*)manager failedForTask:(SDFriendfeedTask*)task;

@end

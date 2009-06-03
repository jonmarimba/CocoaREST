//
//  SDTwitterManager.h
//  SDNet
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDTwitterManager;
@class SDTwitterTask;

@protocol SDTwitterTaskDelegate

@required

- (void) twitterManager:(SDTwitterManager*)manager resultsReadyForTask:(SDTwitterTask*)task;
- (void) twitterManager:(SDTwitterManager*)manager failedForTask:(SDTwitterTask*)task;

@end

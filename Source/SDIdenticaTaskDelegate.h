//
//  SDTwitterManager.h
//  SDNet
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDIdenticaManager;
@class SDIdenticaTask;

@protocol SDIdenticaTaskDelegate

@required

- (void) identicaManager:(SDIdenticaManager*)manager resultsReadyForTask:(SDIdenticaTask*)task;
- (void) identicaManager:(SDIdenticaManager*)manager failedForTask:(SDIdenticaTask*)task;

@end

//
//  SDTwitterEngineDelegateProtocol.h
//  SDTwitterEngineDelegate
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDSocialNetworkManager;
@class SDSocialNetworkTask;

@protocol SDSocialNetworkTaskDelegate

@required

- (void) socialNetworkManager:(SDSocialNetworkManager*)manager resultsReadyForTask:(SDSocialNetworkTask*)task;
- (void) socialNetworkManager:(SDSocialNetworkManager*)manager failedForTask:(SDSocialNetworkTask*)task;

@end

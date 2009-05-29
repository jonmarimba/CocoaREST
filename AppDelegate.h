//
//  AppDelegate.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkTaskDelegateProtocol.h"
#import "SDSocialNetworkManager.h"

@interface AppDelegate : NSObject <SDSocialNetworkTaskDelegate> {
	SDSocialNetworkManager *socialNetworkManager;
}

@end

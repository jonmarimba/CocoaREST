//
//  SDIdenticaTask.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkTask.h"

typedef enum _SDIdenticaTaskType {
	SDIdenticaTaskDoNothing,
	
	SDIdenticaTaskGetPublicTimeline,
	
	SDIdenticaTaskMAX // leave this alone
} SDIdenticaTaskType;

@interface SDIdenticaTask : SDSocialNetworkTask {
	SDIdenticaTaskType type;
}

@property SDIdenticaTaskType type;

@end

//
//  SDIdenticaTask.h
//  SDNet
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTask.h"

typedef enum _SDIdenticaTaskType {
	SDIdenticaTaskDoNothing,
	
	SDIdenticaTaskGetPublicTimeline,
	
	SDIdenticaTaskMAX // leave this alone
} SDIdenticaTaskType;

@interface SDIdenticaTask : SDNetTask {
}

@end

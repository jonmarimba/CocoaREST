//
//  AppDelegate.h
//  SDNet
//
//  Created by Steven Degutis on 5/27/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDTwitterTaskManager.h"

@interface AppDelegate : NSObject {
	SDTwitterTaskManager *manager;
	
	BOOL isWaiting;
	NSArray *results;
	
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passField;
	IBOutlet NSPopUpButton *taskTypeButton;
}

@property BOOL isWaiting;
@property (copy) NSArray *results;

- (IBAction) runTask:(id)sender;

@end

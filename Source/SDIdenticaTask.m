//
//  SDIdenticaTask.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDIdenticaTask.h"

#import "SDIdenticaManager.h"

#import "SDSocialNetworkTask+Subclassing.h"

@implementation SDIdenticaTask

@synthesize type;

- (BOOL) validateType {
	return (type > SDIdenticaTaskDoNothing && type < SDIdenticaTaskMAX);
}

- (BOOL) shouldUseBasicHTTPAuthentication {
	return NO;
}

- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request {
}

- (void) handleHTTPResponse:(NSHTTPURLResponse*)response {
}

- (BOOL) isMultiPartDataBasedOnTaskType {
	return NO;
}

- (SDHTTPMethod) methodBasedOnTaskType {
	return SDHTTPMethodGet;
}

- (NSString*) URLStringBasedOnTaskType {
	NSString *URLStrings[SDIdenticaTaskMAX]; // is this a bad convention? no seriously, i dont know...
	
	URLStrings[SDIdenticaTaskGetPublicTimeline] = @"http://identi.ca/api/statuses/public_timeline.json";
	
	return URLStrings[type];
}

- (void) addParametersToDictionary:(NSMutableDictionary*)parameters {
}

+ (Protocol*) delegateProtocol {
	return @protocol(SDIdenticaTaskDelegate);
}

- (void) sendResultsToDelegate {
	[(id)manager.delegate identicaManager:(id)manager resultsReadyForTask:self];
}

- (void) sendErrorToDelegate {
	[(id)manager.delegate identicaManager:(id)manager failedForTask:self];
}

@end

//
//  SDSocialNetworkTask+Subclassing.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDSocialNetworkTask.h"

#import "NSData+Base64.h"
#import "NSString+UUID.h"
#import "NSColor+Hex.h"

typedef enum _SDHTTPMethod {
	SDHTTPMethodGet,
	SDHTTPMethodPost
} SDHTTPMethod;

@interface SDSocialNetworkTask (Subclassing)

// NOTE: the following MUST be overridden by subclasses; superclass does NOT implement these

- (BOOL) validateType;
- (BOOL) shouldUseBasicHTTPAuthentication;
- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request;
- (void) handleHTTPResponse:(NSHTTPURLResponse*)response;

- (BOOL) isMultiPartDataBasedOnTaskType;
- (SDHTTPMethod) methodBasedOnTaskType;
- (NSString*) URLStringBasedOnTaskType;
- (void) addParametersToDictionary:(NSMutableDictionary*)parameters;

+ (Protocol*) delegateProtocol;
- (void) sendResultsToDelegate;
- (void) sendErrorToDelegate;

// MISC: general helper methods, courtesy of the superclass

- (NSString*) encodeString:(NSString*)string;
- (NSString*) queryStringFromDictionary:(NSDictionary*)queryUnits;
- (NSData*) postBodyDataFromDictionary:(NSDictionary*)dictionary;
+ (NSString*) stringBoundary;
- (NSString*) errorString;

@end

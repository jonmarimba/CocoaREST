//
//  SDSocialNetworkTask+Subclassing.h
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/29/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDNetTask.h"

#import "NSData+Base64.h"
#import "NSString+UUID.h"
#import "NSColor+Hex.h"

// the rationale for not putting much of this info into SDSocialNetworkTask.h is that it's not
// particularly useful or relevant to users of this library, only for subclassers.

// similarly, the top half of the category might have been a protocol, but that would require
// a separate object to be involved. plus, SDSocialNetworkTask would have to be concrete,
// which complicates the fact that *Task & *Manager are a pair of subclassable classes.

typedef enum _SDHTTPMethod {
	SDHTTPMethodGet,
	SDHTTPMethodPost
} SDHTTPMethod;

typedef enum _SDParseFormat {
	SDParseFormatNone,
	SDParseFormatJSON,
	SDParseFormatXML,
	SDParseFormatImage,
} SDParseFormat;

@interface SDNetTask (Subclassing)

// NOTE: the following MUST be overridden by subclasses; superclass does NOT implement these
// (ok well it really does, but let's pretend it doesn't)

- (id) copyWithZone:(NSZone*)zone;
- (BOOL) validateType;
- (BOOL) shouldUseBasicHTTPAuthentication;
- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request;
- (void) handleHTTPResponse:(NSHTTPURLResponse*)response;

- (BOOL) isMultiPartDataBasedOnTaskType;
- (SDHTTPMethod) methodBasedOnTaskType;
- (NSString*) URLStringBasedOnTaskType;
- (SDParseFormat) parseFormatBasedOnTaskType;
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

//
//  SDTwitterFetchTask.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDNetTask.h"
#import "SDNetTaskManager.h"

#import "SDNetTask+Subclassing.h"

#import "YAJLDecoder.h"

@interface SDNetTask (Private)

- (void) _appendToData:(NSMutableData*)data formatWithUTF8:(NSString*)format, ...;
- (void) _sendResultsToDelegate;
- (void) _sendResultsToDelegateFromMainThread;
- (void) _setBasicHTTPAuthorizationForRequest:(NSMutableURLRequest*)request;
- (void) _setURLAndParametersForRequest:(NSMutableURLRequest*)request;

@end

@implementation SDNetTask

@synthesize type;

@synthesize results;
@synthesize errorCode;
@synthesize error;
@synthesize taskID;

+ (id) taskWithManager:(SDNetTaskManager*)newManager {
	return [[[self alloc] initWithManager:newManager] autorelease];
}

- (id) initWithManager:(SDNetTaskManager*)newManager {
	if (self = [super init]) {
		manager = [newManager retain];
		
		if (manager == nil) {
			[self release];
			return nil;
		}
		
		taskID = [[NSString stringWithNewUUID] retain];
	}
	return self;
}

- (void) dealloc {
	[taskID release], taskID = nil;
	[results release], results = nil;
	[manager release], manager = nil;
	[super dealloc];
}

- (id) copyWithZone:(NSZone*)zone {
	SDNetTask *task = [[[self class] alloc] initWithManager:manager];
	
	// we only copy the pre-run settings, as we want the rest of the new object to be unique
	task.type = self.type;
	
	return task;
}

// MARK: -
// MARK: Main methods

- (void) run {
	[manager runTask:self];
}

- (void) cancel {
	@synchronized(self) {
		manager = nil;
	}
}

- (void) main {
	if ([self validateType] == NO) {
		errorCode = SDSocialNetworkTaskErrorInvalidType;
		[self _sendResultsToDelegate];
		return;
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval:30.0];
	
	[self _setURLAndParametersForRequest:request];
	[self setUniqueApplicationIdentifiersForRequest:request];
	
	if ([self shouldUseBasicHTTPAuthentication])
		[self _setBasicHTTPAuthorizationForRequest:request];
	
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	NSError *errorFromParser = nil;
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
	
	if (connectionError) {
		underlyingError = connectionError;
		
		// commented out the next line because some APIs are using HTTP error codes as return values, which is super lame
		
//		errorCode = SDSocialNetworkTaskErrorConnectionFailed;
//		[self _sendResultsToDelegate];
//		return;
	}
	
	if (data == nil) {
		errorCode = SDSocialNetworkTaskErrorConnectionDataIsNil;
		[self _sendResultsToDelegate];
		return;
	}
	
	switch ([self parseFormatBasedOnTaskType]) {
		case SDParseFormatJSON: {
			YAJLDecoder *decoder = [[[YAJLDecoder alloc] init] autorelease];
			results = [[decoder parse:data error:&errorFromParser] retain];
			
			break;
		}
		case SDParseFormatImage:
			results = [[[NSImage alloc] initWithData:data] autorelease];
			break;
		case SDParseFormatNone:
			results = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
			break;
	}
	
	[self handleHTTPResponse:response];
	
	if (errorFromParser) {
		errorCode = SDSocialNetworkTaskErrorParserFailed;
		underlyingError = errorFromParser;
	}
	else if (results == nil)
		errorCode = SDSocialNetworkTaskErrorParserDataIsNil;
	
	[self _sendResultsToDelegate];
}

- (void) _sendResultsToDelegate {
	[self performSelectorOnMainThread:@selector(_sendResultsToDelegateFromMainThread) withObject:nil waitUntilDone:YES];
}

- (void) _sendResultsToDelegateFromMainThread {
	// we enter the main thread, waiting patiently til the delegate is done using us like a peice of meat
	// delegate can safely access all of our properties now
	
	if (errorCode == SDSocialNetworkTaskErrorNone) {
		if ([manager.delegate conformsToProtocol:[[self class] delegateProtocol]])
			[self sendResultsToDelegate];
	}
	else {
		// we'll create our error manually and let the delegate get all touchy-feely with it all they want
		
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:[self errorString] forKey:NSLocalizedDescriptionKey];
		if (underlyingError)
			[userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
		
		// we don't retain the error object, because the pool won't drain until the delegate is done anyway
		error = [NSError errorWithDomain:@"SDSocialNetworkDomain" code:errorCode userInfo:userInfo];
		
		if ([manager.delegate conformsToProtocol:[[self class] delegateProtocol]])
			[self sendErrorToDelegate];
	}
}

- (void) _setBasicHTTPAuthorizationForRequest:(NSMutableURLRequest*)request {
	if (manager.username == nil || manager.password == nil)
		return;
	
	// Set header for HTTP Basic authentication explicitly, to avoid problems with proxies and other intermediaries
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", manager.username, manager.password];
	NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
	[request setValue:authValue forHTTPHeaderField:@"Authorization"];
}

- (void) _setURLAndParametersForRequest:(NSMutableURLRequest*)request {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	SDHTTPMethod method = [self methodBasedOnTaskType];
	
	NSString *URLString = [self URLStringBasedOnTaskType];
	NSAssert(URLString != nil, @"URLString == nil; either `type` is invalid, or URL method is not complete");
	
	[self addParametersToDictionary:parameters];
	
	switch (method) {
		case SDHTTPMethodGet: {
			NSString *queryString = [self queryStringFromDictionary:parameters];
			[request setHTTPMethod:@"GET"];
			if ([queryString length] > 0)
				URLString = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
			break;
		}
		case SDHTTPMethodPost:
			[request setHTTPMethod:@"POST"];
			if ([self isMultiPartDataBasedOnTaskType] == YES) {
				NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [SDNetTask stringBoundary]];
				[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
				
				[request setHTTPBody:[self postBodyDataFromDictionary:parameters]];
			}
			else {
				NSString *queryString = [self queryStringFromDictionary:parameters];
				[request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
			}
			break;
	}
	
	[request setURL:[NSURL URLWithString:URLString]];
}

// MARK: -
// MARK: Subclassable Methods

- (BOOL) validateType { return NO; }
- (BOOL) shouldUseBasicHTTPAuthentication { return NO; }
- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request {}
- (void) handleHTTPResponse:(NSHTTPURLResponse*)response {}

- (BOOL) isMultiPartDataBasedOnTaskType { return NO; }
- (SDHTTPMethod) methodBasedOnTaskType { return SDHTTPMethodGet; }
- (NSString*) URLStringBasedOnTaskType { return nil; }
- (SDParseFormat) parseFormatBasedOnTaskType { return SDParseFormatJSON; }
- (void) addParametersToDictionary:(NSMutableDictionary*)parameters {}

- (Protocol*) delegateProtocol { return NULL; }
- (void) sendResultsToDelegate {}
- (void) sendErrorToDelegate {}

// MARK: -
// MARK: General Helper Methods

- (NSString*) queryStringFromDictionary:(NSDictionary*)queryUnits {
	NSMutableArray *queryParts = [NSMutableArray array];
	for (NSString *key in queryUnits) {
		NSString *object = [queryUnits objectForKey:key];
		
		NSString *queryPart = [NSString stringWithFormat:@"%@=%@", key, [self encodeString:object]];
		[queryParts addObject:queryPart];
	}
	
	return [queryParts componentsJoinedByString:@"&"];
}

- (NSString*) encodeString:(NSString*)string {
	// stolen from Matt Gemmell (though he probably stole it from elsewhere, so it should be okay)
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)string,
																		   NULL,
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}

- (void) _appendToData:(NSMutableData*)data formatWithUTF8:(NSString*)format, ... {
	va_list ap;
	va_start(ap, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
	
	NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:stringData];
	
	[str release];
}

- (NSData*) postBodyDataFromDictionary:(NSDictionary*)dictionary {
	// setting up string boundaries
	NSString *stringBoundary = [SDNetTask stringBoundary];
	NSData *stringBoundaryData = [[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *stringBoundaryFinalData = [[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableData *postBody = [NSMutableData data];
	
	// necessary??
	[self _appendToData:postBody formatWithUTF8:@"\r\n"];
	
	for (NSString *key in dictionary) {
		[postBody appendData:stringBoundaryData];
		
		id object = [dictionary objectForKey:key];
		
		if ([object isKindOfClass:[NSString class]]) {
			[self _appendToData:postBody formatWithUTF8:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
			[self _appendToData:postBody formatWithUTF8:@"%@", object];
		}
		//		else if ([object isKindOfClass:[NSData class]]) {
		// normally we would just append this data, but i dont know what content-type to give it.
		// if we can safely skip Content-Type, then we can just copy the above method and simply
		// call -appendData:. also, when would we even have only NSData? come to think of it,
		// we might as well just delete this whole block, comments and all.
		//		}
		else if ([object isKindOfClass:[NSImage class]]) {
			NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithData:[object TIFFRepresentation]] autorelease];
			NSData *imageData = [rep representationUsingType:NSPNGFileType properties:nil];
			
			[self _appendToData:postBody formatWithUTF8:@"Content-Disposition: form-data; name=\"%@\"; filename=\"astyle.png\"\r\n", key];
			[self _appendToData:postBody formatWithUTF8:@"Content-Type: image/png\r\n\r\n"];
			[postBody appendData:imageData];
		}
	}
	
	[postBody appendData:stringBoundaryFinalData];
	
	return postBody;
}

+ (NSString*) stringBoundary {
	return @"SDthisisnotatestokaymaybeitisSD";
}

- (NSString*) errorString {
	NSString *errorStrings[SDSocialNetworkTaskErrorMAX];
	errorStrings[SDSocialNetworkTaskErrorInvalidType] = @"type property is invalid";
	errorStrings[SDSocialNetworkTaskErrorManagerNotSet] = @"manager property is NULL; only use -runTask: to run a task!";
	errorStrings[SDSocialNetworkTaskErrorConnectionDataIsNil] = @"Connection returned NULL data";
	errorStrings[SDSocialNetworkTaskErrorConnectionFailed] = @"Connection failed with error";
	errorStrings[SDSocialNetworkTaskErrorParserFailed] = @"Parser failed with error";
	errorStrings[SDSocialNetworkTaskErrorParserDataIsNil] = @"Parser returned NULL data";
	return errorStrings[errorCode];
}

@end

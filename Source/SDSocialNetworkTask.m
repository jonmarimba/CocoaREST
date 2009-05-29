//
//  SDTwitterFetchTask.m
//  SDSocialNetwork
//
//  Created by Steven Degutis on 5/28/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDSocialNetworkTask.h"
#import "SDSocialNetworkManager.h"

#import "SDSocialNetworkTask+Subclassing.h"

#import "YAJLDecoder.h"

@interface SDSocialNetworkTask (Private)

- (void) _appendToData:(NSMutableData*)data formatWithUTF8:(NSString*)format, ...;
- (void) _sendResultsToDelegate;
- (void) _sendResultsToDelegateFromMainThread;
- (void) _setBasicHTTPAuthorizationForRequest:(NSMutableURLRequest*)request;

@end

@implementation SDSocialNetworkTask

@synthesize results;
@synthesize errorCode;
@synthesize error;
@synthesize taskID;

+ (id) taskWithManager:(SDSocialNetworkManager*)newManager {
	return [[[self alloc] initWithManager:newManager] autorelease];
}

- (id) initWithManager:(SDSocialNetworkManager*)newManager {
	if (self = [super init]) {
		manager = newManager;
		
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
	[super dealloc];
}

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
	
	[self setURLAndParametersForRequest:request];
	[self setUniqueApplicationIdentifiersForRequest:request];
	
	if ([self shouldUseBasicHTTPAuthentication])
		[self _setBasicHTTPAuthorizationForRequest:request];
	
	NSHTTPURLResponse *response = nil;
	NSError *connectionError = nil;
	NSError *errorFromYAJL = nil;
	
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
	
	YAJLDecoder *decoder = [[[YAJLDecoder alloc] init] autorelease];
	results = [[decoder parse:data error:&errorFromYAJL] retain];
	
	[self handleHTTPResponse:response];
	
	if (errorFromYAJL) {
		errorCode = SDSocialNetworkTaskErrorParserFailed;
		underlyingError = errorFromYAJL;
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
	NSLog(@"in here %@ %@", manager.username, manager.password);
	
	if (manager.username == nil || manager.password == nil)
		return;
	
	// Set header for HTTP Basic authentication explicitly, to avoid problems with proxies and other intermediaries
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", manager.username, manager.password];
	NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
	[request setValue:authValue forHTTPHeaderField:@"Authorization"];
}

// MARK: -
// MARK: Subclassable Methods

- (BOOL) validateType { return NO; }
- (BOOL) shouldUseBasicHTTPAuthentication { return NO; }
- (void) setURLAndParametersForRequest:(NSMutableURLRequest*)request {}
- (void) setUniqueApplicationIdentifiersForRequest:(NSMutableURLRequest*)request {}
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
	NSString *stringBoundary = [SDSocialNetworkTask stringBoundary];
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

//
//  HTTPRequest.h
//  radelcom
//
//  Created by Jeffrey Oloresisimo on 2013-04-05.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import "HTTPRequest.h"
#import "Reachability.h"


NSString* const HTTPHeaderFieldAccept = @"Accept";
NSString* const HTTPHeaderFieldAuthorization = @"Authorization";
NSString* const HTTPHeaderFieldCacheControl = @"Cache-Control";
NSString* const HTTPHeaderFieldContentType = @"Content-Type";
NSString* const HTTPHeaderFieldHost = @"Host";
NSString* const HTTPHeaderFieldUserAgent = @"User-Agent";


@interface HTTPRequest ()

@property (nonatomic, copy) NSURL* url;

- (void)connectionTimedOut:(NSURLConnection*)connection;
- (void)reachabilityChanged:(NSNotification* )nitification;
- (NSString*)getDefaultUserAgent;

@end


@implementation HTTPRequest {
    NSHTTPURLResponse*  _response;
    NSMutableData*      _responseData;
	NSURLConnection*	_connection;
    
    NetworkStatus       _status;
    BOOL                _pending;
	
	HTTPRequestHandler	_requestHandler;
	HTTPResponseHandler _responseHandler;
}

@synthesize username = _username;
@synthesize password = _password;
@synthesize url = _url;
@synthesize requestHeaders = _requestHeaders;
@synthesize requestBody = _requestBody;

@synthesize method = _method;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize allowInvalidCerts = _allowInvalidCerts;

+ (id)requestWithURL:(NSURL *)url requestMethod:(HTTPMethod)method requestData:(NSData *)data
{
    HTTPRequest* request = [[self alloc] init];
    request.url = url;
    request.method = method;
    [request.requestBody setData:data];
	
    return request;
}

- (BOOL)hasNetworkConnection
{
	return _status != NotReachable;
}

- (id)init
{
    self = [super init];
    if (self) {
        _responseData = [[NSMutableData alloc] init];
        _timeoutInterval = 30;
        _allowInvalidCerts = NO;
        _pending = NO;
        _status = -1;
		_requestHeaders = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						   @"*/*", HTTPHeaderFieldAccept,
						   [self getDefaultUserAgent], HTTPHeaderFieldUserAgent,
						   nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        Reachability* reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
        [reachability startNotifier];
    }
	
    return self;
}

- (void)cancel
{
	[_connection cancel];
	_connection = nil;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_requestHeaders setValue:value forKey:field];
}

- (void)performWithRequestHandler:(HTTPRequestHandler)requestHandler responseHandler:(HTTPResponseHandler)responseHandler
{
	_requestHandler = [requestHandler copy];
	_responseHandler = [responseHandler copy];
    
    if (_status == NotReachable) {
        _pending = YES;
        return;
    }
    
	// handle pre-request configuration, last chance to set request properties
	if (_requestHandler) {
		_requestHandler();
	}	
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    [request setAllHTTPHeaderFields:_requestHeaders];
	
	switch (_method) {
		case HTTPMethodGET:
			[request setHTTPMethod:@"GET"];
			break;
		case HTTPMethodPOST:
			[request setHTTPMethod:@"POST"];
			if ([_requestBody isKindOfClass:[NSData class]]) {
				[request setHTTPBody:_requestBody];
			} else {
				[request setHTTPBodyStream:_requestBody];
			}
			break;
		case HTTPMethodPUT:
			[request setHTTPMethod:@"PUT"];
			if ([_requestBody isKindOfClass:[NSData class]]) {
				[request setHTTPBody:_requestBody];
			} else {
				[request setHTTPBodyStream:_requestBody];
			}
			break;
		case HTTPMethodDELETE:
			[request setHTTPMethod:@"DELETE"];
			break;
        default: {
            NSError* error = [NSError errorWithDomain:NSStringFromClass([self class]) code:400 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Bad Request", @"") forKey:NSLocalizedDescriptionKey]];
            _responseHandler(nil, nil, error);
            return;
        }
	}
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[self performSelector:@selector(connectionTimedOut:) withObject:_connection afterDelay:_timeoutInterval];
}

- (void)performWithResponseHandler:(HTTPResponseHandler)responseHandler
{
	[self performWithRequestHandler:NULL responseHandler:responseHandler];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimedOut:) object:connection];
	
    _response = [response copy];
	_responseData.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	_responseHandler(_responseData, _response, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimedOut:) object:connection];
    
    _responseHandler(_responseData, _response, error);
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimedOut:) object:connection];
    
    BOOL canAuthenticate = NO;
    if (![[_url host] isEqualToString:challenge.protectionSpace.host] || [challenge previousFailureCount] > 0) {
        canAuthenticate = NO;
    } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (_allowInvalidCerts) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            canAuthenticate = YES;
        }
    } else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
			  [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        canAuthenticate = YES;
    }
    
    if (canAuthenticate == NO) {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

#pragma mark - PRIVATE
- (void)connectionTimedOut:(NSURLConnection*)connection
{
	[self cancel];
	
	NSError* error = [NSError errorWithDomain:NSStringFromClass([self class]) code:408 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"The request timed out.", @"") forKey:NSLocalizedDescriptionKey]];
    _responseHandler(nil, nil, error);
}

- (void)reachabilityChanged:(NSNotification* )nitification
{
	Reachability* reachability = [nitification object];
	NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    _status = [reachability currentReachabilityStatus];
    
    if (_pending && _status != NotReachable) {
        [self performWithRequestHandler:_requestHandler responseHandler:_responseHandler];
    }
}

- (NSString*)getDefaultUserAgent
{
	return [NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

@end

//
//  HTTPRequest.h
//  radelcom
//
//  Created by Jeffrey Oloresisimo on 2013-04-05.
//  Copyright (c) 2013 radelcom. All rights reserved.
//


typedef void (^HTTPRequestHandler)();
typedef void (^HTTPResponseHandler)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error);


typedef enum {
    HTTPMethodUnkown,
	HTTPMethodGET,
	HTTPMethodPOST,
	HTTPMethodPUT,
	HTTPMethodDELETE
} HTTPMethod;


NSString* const HTTPHeaderFieldAccept;
NSString* const HTTPHeaderFieldAuthorization;
NSString* const HTTPHeaderFieldCacheControl;
NSString* const HTTPHeaderFieldContentType;
NSString* const HTTPHeaderFieldHost;
NSString* const HTTPHeaderFieldUserAgent;


@interface HTTPRequest : NSObject


@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy, readonly) NSURL* url;
@property (nonatomic, copy, readonly) NSMutableDictionary* requestHeaders;

@property (nonatomic, strong) id requestBody;

@property (nonatomic) BOOL allowInvalidCerts;
@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic) HTTPMethod method;


+ (id)requestWithURL:(NSURL*)url requestMethod:(HTTPMethod)method requestData:(NSData*)data;

- (void)cancel;
- (void)setValue:(NSString*)value forHTTPHeaderField:(NSString*)field;
- (void)performWithRequestHandler:(HTTPRequestHandler)requestHandler responseHandler:(HTTPResponseHandler)responseHandler;
- (void)performWithResponseHandler:(HTTPResponseHandler)responseHandler;
- (BOOL)hasNetworkConnection;

@end

//
//  SyncOperation.m
//  radelcom
//
//  Created by Jeffrey Leo Oloresisimo on 2013-05-10.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import "SyncOperation.h"



@implementation SyncOperation

@synthesize cancel = _cancel;
@synthesize progress = _progress;
@synthesize completed = _completed;


+ (id)operationWithURL:(NSURL *)url
{
	return [self requestWithURL:url requestMethod:HTTPMethodUnkown requestData:nil];
}


#pragma mark - SyncOperation Protocol

- (void)performOperation
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"[SyncOperation performOperation] SUBCLASS SHOULD IMPLEMENT THIS" userInfo:nil];
}

- (void)cancelOperation
{
	[self cancel];
	
	_cancel = YES;
	_progress = NO;
	_completed = NO;
}


#pragma mark - HTTPRequest Methods

- (void)performWithRequestHandler:(HTTPRequestHandler)requestHandler responseHandler:(HTTPResponseHandler)responseHandler
{
	[super performWithRequestHandler:^() {
		requestHandler();
		_cancel = NO;
		_progress = YES;
		_completed = NO;
    } responseHandler:^(NSData* data, NSHTTPURLResponse* response, NSError* error) {
		responseHandler(data, response, error);
        _cancel = NO;
		_progress = NO;
		_completed = YES;
    }];
}




@end

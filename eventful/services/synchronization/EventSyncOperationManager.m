//
//  EventSyncOperationManager.m
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "EventSyncOperationManager.h"
#import "EventSyncOperation.h"


@implementation EventSyncOperationManager


@synthesize appKey = _appKey;

- (NSString *)coreDataName
{
	return @"eventful";
}

- (void)getEventsWithParameter:(NSString *)parameter
{
	// append the app key at the end 
	NSString* finalParam = [parameter stringByAppendingFormat:@"&app_key=%@", _appKey];
	EventSyncOperation* operation = [EventSyncOperation operationWithURL:_url parameter:finalParam];
	[self addOperation:operation];
}

@end

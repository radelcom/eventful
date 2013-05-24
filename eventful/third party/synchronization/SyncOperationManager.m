//
//  SyncOperationManager.m
//  radelcom
//
//  Created by Jeffrey Leo Oloresisimo on 2013-05-10.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import "SyncOperationManager.h"

@implementation SyncOperationManager


@synthesize url = _url;
@synthesize allowInvalidCerts = _allowInvalidCerts;

+ (id)sharedSyncOperationManager
{
    static id sharedSyncManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSyncManager = [[self alloc] initSyncOperationManager];
    });
    
    return sharedSyncManager;
}

- (id)initSyncOperationManager
{
	self = [super init];
	if (self) {
		_operations = [NSMutableDictionary new];
	}
	
	return self;
}

- (void)addOperation:(SyncOperation *)operation
{
	[operation performOperation];
	
	NSValue* key = [NSValue valueWithNonretainedObject:operation];
	[_operations setObject:operation forKey:key];
}

- (void)removeOperation:(SyncOperation *)operation
{
	[operation cancelOperation];
	
	NSValue* key = [NSValue valueWithNonretainedObject:operation];
	[_operations removeObjectForKey:key];
}

@end



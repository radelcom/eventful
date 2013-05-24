//
//  EventSyncOperationManager.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "SyncOperationManager.h"

@interface EventSyncOperationManager : SyncOperationManager
{
	NSString*	_appKey;
}

@property (nonatomic, strong) NSString* appKey;

// Events
- (void)getEventsWithParameter:(NSString*)parameter;

@end

//
//  EventSyncOperation.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "SyncOperation.h"

@interface EventSyncOperation : SyncOperation

+ (id)operationWithURL:(NSURL *)url parameter:(NSString*)parameter;

@end

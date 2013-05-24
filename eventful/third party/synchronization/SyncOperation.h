//
//  SyncOperation.h
//  radelcom
//
//  Created by Jeffrey Leo Oloresisimo on 2013-05-10.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequest.h"


@protocol SyncOperation <NSObject>

@property (nonatomic, readonly, getter = isCanceled) BOOL cancel;
@property (nonatomic, readonly, getter = isExecuting) BOOL progress;
@property (nonatomic, readonly, getter = isFinished) BOOL completed;

- (void)performOperation;
- (void)cancelOperation;

@end




@interface SyncOperation : HTTPRequest <SyncOperation>

+ (id)operationWithURL:(NSURL *)url;

@end




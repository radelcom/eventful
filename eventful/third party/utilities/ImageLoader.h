//
//  ImageLoader.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ImageLoaderCachingPolicyNone = 0,
	ImageLoaderCachingPolicyInMemory,
    ImageLoaderCachingPolicyInDisk,
} ImageLoaderCachingPolicy;

@protocol ImageLoaderDelegate;

@interface ImageLoader : NSObject
{
	__weak id<ImageLoaderDelegate>		_delegate;
	NSMutableDictionary*				_requests;
	NSMutableDictionary*				_cachedImages;
}

@property (nonatomic, weak) id<ImageLoaderDelegate> delegate;

- (UIImage*) cachedImageForUrl:(NSString*)url;
- (void) addRequest:(NSString*)uri forKey:(id)key cache:(ImageLoaderCachingPolicy)cache;
- (void) removeRequestForKey:(id)key;
- (void) removeAllRequests;

@end


@protocol ImageLoaderDelegate <NSObject>

- (void)imageLoader:(ImageLoader*)imageLoader didFinishLoadingImage:(UIImage*)image forKey:(id)key;
- (void)imageLoader:(ImageLoader*)imageLoader didCancelLoadingForKey:(id)key;

@end
//
//  ImageLoader.m
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "ImageLoader.h"
#import "HTTPRequest.h"


@implementation ImageLoader

@synthesize delegate = _delegate;

- (id) init
{
	self = [super init];
	if(self != nil)
	{
		_cachedImages = [[NSMutableDictionary alloc] init];
		_requests = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (UIImage *)cachedImageForUrl:(NSString *)url
{
	UIImage* image = [_cachedImages objectForKey:[self imageNameFromURL:url]];
	if (image == nil)
	{
		image = [self loadFromDisk:url];
	}
	return image;
}

- (void) addRequest:(NSString*)url forKey:(id)key cache:(ImageLoaderCachingPolicy)cache
{
	if([url length] == 0)
		return;
	
	__block ImageLoaderCachingPolicy cachingPolicy = cache;
	__block id origKey = key;
	HTTPRequest* request = [HTTPRequest requestWithURL:[NSURL URLWithString:url] requestMethod:HTTPMethodGET requestData:nil];
	[request performWithResponseHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
		if (_delegate && [_delegate respondsToSelector:@selector(imageLoader:didFinishLoadingImage:forKey:)]) {
			UIImage* image = [UIImage imageWithData:data];
			[_delegate imageLoader:self didFinishLoadingImage:image forKey:origKey];
			
			if (image) {
				if (cachingPolicy == ImageLoaderCachingPolicyInMemory) {
					[_cachedImages setObject:image forKey:[self imageNameFromURL:request.url.absoluteString]];
				} else if (cachingPolicy == ImageLoaderCachingPolicyInDisk) {
					NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self imageNameFromURL:request.url.absoluteString]];
					NSString *dir = [imagePath stringByDeletingLastPathComponent];
					[[NSFileManager defaultManager] createDirectoryAtPath:dir
											  withIntermediateDirectories:YES
															   attributes:nil
																	error:nil];
					
					[data writeToFile:imagePath options:NSDataWritingAtomic error:nil];
				}
			}
			
		}
	}];
	
	[_requests setObject:request forKey:[self keyForRequest:key]];
}

- (void)removeRequestForKey:(id)key
{
	HTTPRequest* request = [_requests objectForKey:[self keyForRequest:key]];
	[request cancel];
	
	[_requests removeObjectForKey:[self keyForRequest:key]];
}

- (void) removeAllRequests
{
	[_requests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
		HTTPRequest* request = (HTTPRequest*)obj;
		[request cancel];
	}];
	[_requests removeAllObjects];
}

#pragma mark - Private

- (UIImage*)loadFromDisk:(NSString*)url
{
	NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self imageNameFromURL:url]];	
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
}

- (NSValue *)keyForRequest:(HTTPRequest*)request
{
	// use this to make ANY object a key for NSDictionary without having it implementing NSCopying protocol
	return [NSValue valueWithNonretainedObject:request];
}

- (NSString*)imageNameFromURL:(NSString *)url
{
	// NOTE: [NSString lastPathComponent] does not include fragments of a url('?' or '#') e.g. example.com/icon?name=something
	NSRange nameRange = [url rangeOfString:[url lastPathComponent] options:NSBackwardsSearch];
	return [url substringFromIndex:nameRange.location];
}

@end
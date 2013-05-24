//
//  EventsListViewController.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "ImageLoader.h"


@interface EventsListViewController : CoreDataTableViewController <ImageLoaderDelegate>
{
	NSString*	_currentEventParameter;
}

@property (nonatomic, strong) NSString* currentEventParameter;

@end

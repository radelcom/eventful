//
//  Venue.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * display;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) Event *event;

@end

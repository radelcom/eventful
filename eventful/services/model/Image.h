//
//  Image.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) Event *event;

@end

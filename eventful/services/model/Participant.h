//
//  Participant.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Participant : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * linker;
@property (nonatomic, retain) NSString * shortBio;
@property (nonatomic, retain) Event *event;

@end

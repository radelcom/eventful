//
//  Event.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, Participant, Venue;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * beginDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Venue *venue;
@property (nonatomic, retain) NSSet *participants;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addParticipantsObject:(Participant *)value;
- (void)removeParticipantsObject:(Participant *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end

//
//  EventSyncOperation.m
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "EventSyncOperation.h"
#import "EventSyncOperationManager.h"

#import "Event.h"
#import "Venue.h"
#import "Image.h"
#import "Participant.h"



@interface EventSyncOperation ()

- (id)getPropertyFromDictionary:(NSDictionary*)dictionary forKey:(NSString*)key;

@end


@implementation EventSyncOperation

+ (id)operationWithURL:(NSURL *)url parameter:(NSString*)parameter
{
	NSMutableString* finalURI = [NSMutableString stringWithString:@"/events/search"];
	if ([parameter length]) {
		[finalURI appendFormat:@"?%@", parameter];
	}
	
	
	EventSyncOperation* operation = [self requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url.absoluteString, finalURI]]
										   requestMethod:HTTPMethodGET
											 requestData:nil];
    return operation;
}


#pragma mark - EventSyncOperation Methods

- (void)performOperation
{
	[self performWithRequestHandler:^() {
        self.method = HTTPMethodGET;
    } responseHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        // sync to core data
		NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //2013-06-25 19:30:00
		
		// no results
		if (![self getPropertyFromDictionary:jsonObject forKey:@"events"]) 
			return;
		
		for (NSDictionary* d in [[jsonObject objectForKey:@"events"] objectForKey:@"event"]) {
			NSError* error = nil;
			
			// set event properties
			NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@", [self getPropertyFromDictionary:d forKey:@"id"]];
			Event* event = [[EventSyncOperationManager sharedSyncOperationManager] managedObjectWithName:@"Event" predicate:predicate error:&error];
			if (!event) {
				event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext]];
				event.id = [d objectForKey:@"id"];
			}
			
			event.title = [self getPropertyFromDictionary:d forKey:@"title"];
			event.url = [self getPropertyFromDictionary:d forKey:@"url"];
			event.price = [self getPropertyFromDictionary:d forKey:@"price"];
			
			if ([self getPropertyFromDictionary:d forKey:@"start_time"]) {
				event.beginDate = [dateFormatter dateFromString:[self getPropertyFromDictionary:d forKey:@"start_time"]];
			}
			if ([self getPropertyFromDictionary:d forKey:@"stop_time"]) {
				event.endDate = [dateFormatter dateFromString:[self getPropertyFromDictionary:d forKey:@"stop_time"]];
			}
			
			
			// set related venue properties
			predicate = [NSPredicate predicateWithFormat:@"id = %@", [self getPropertyFromDictionary:d forKey:@"venue_id"]];
			Venue* venue = [[EventSyncOperationManager sharedSyncOperationManager] managedObjectWithName:@"Venue" predicate:predicate error:&error];
			if (!venue) {
				venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:[[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext]];
				venue.id = [self getPropertyFromDictionary:d forKey:@"venue_id"];
			}
			
			venue.name = [self getPropertyFromDictionary:d forKey:@"venue_name"];
			venue.url = [self getPropertyFromDictionary:d forKey:@"venue_url"];
			venue.display = [self getPropertyFromDictionary:d forKey:@"venue_display"];
			venue.address = [self getPropertyFromDictionary:d forKey:@"venue_address"];
			event.venue = venue;
			
			
			// set related participants
			NSDictionary* performerDictionary = [self getPropertyFromDictionary:d forKey:@"performers"];
			if (performerDictionary)
			{
				// NOTE: result can either be an array or dictionary
				id performer = [performerDictionary objectForKey:@"performer"];
				NSMutableArray* performers = [NSMutableArray array];
				if ([performer isKindOfClass:[NSArray class]]) {
					[performers addObjectsFromArray:performer];
				} else {
					[performers addObject:performer];
				}
				
				for (NSDictionary* performer in performers) {
					predicate = [NSPredicate predicateWithFormat:@"id = %@", [self getPropertyFromDictionary:performer forKey:@"id"]];
					Participant* participant = [[EventSyncOperationManager sharedSyncOperationManager] managedObjectWithName:@"Participant" predicate:predicate error:&error];
					if (!participant) {
						participant = [NSEntityDescription insertNewObjectForEntityForName:@"Participant" inManagedObjectContext:[[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext]];
						participant.id = [performer objectForKey:@"id"];
						[event addParticipantsObject:participant];
					}
					
					participant.name = [self getPropertyFromDictionary:performer forKey:@"name"];
					participant.creator = [self getPropertyFromDictionary:performer forKey:@"creator"];
					participant.linker = [self getPropertyFromDictionary:performer forKey:@"linker"];
					participant.url = [self getPropertyFromDictionary:performer forKey:@"url"];
					participant.shortBio = [self getPropertyFromDictionary:performer forKey:@"short_bio"];
				}
			}			
			
			
			// set related images properties
			[event removeImages:event.images];
			
			// small image
			
			if (![self getPropertyFromDictionary:d forKey:@"image"])
				continue;
			
			NSDictionary* imageDictionary = [self getPropertyFromDictionary:d forKey:@"image"];
			imageDictionary = [self getPropertyFromDictionary:imageDictionary forKey:@"small"];
			Image* image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:[[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext]];
			if (image) {
				image.url = [self getPropertyFromDictionary:imageDictionary forKey:@"url"];
				image.width = [NSNumber numberWithFloat:[[self getPropertyFromDictionary:imageDictionary forKey:@"width"] floatValue]];
				image.height = [NSNumber numberWithFloat:[[self getPropertyFromDictionary:imageDictionary forKey:@"height"] floatValue]];
				image.type = @"small";
				[event addImagesObject:image];
			}
			
			// medium image
			imageDictionary = [self getPropertyFromDictionary:d forKey:@"image"];
			imageDictionary = [self getPropertyFromDictionary:imageDictionary forKey:@"medium"];
			image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:[[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext]];
			if (image) {
				image.url = [self getPropertyFromDictionary:imageDictionary forKey:@"url"];
				image.width = [NSNumber numberWithFloat:[[self getPropertyFromDictionary:imageDictionary forKey:@"width"] floatValue]];
				image.height = [NSNumber numberWithFloat:[[self getPropertyFromDictionary:imageDictionary forKey:@"height"] floatValue]];
				image.type = @"medium";
				[event addImagesObject:image];
			}
			
			// thumb image
			imageDictionary = [self getPropertyFromDictionary:d forKey:@"image"];
			imageDictionary = [self getPropertyFromDictionary:imageDictionary forKey:@"thumb"];
			image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:[[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext]];
			if (image) {
				image.url = [self getPropertyFromDictionary:imageDictionary forKey:@"url"];
				image.width = [NSNumber numberWithFloat:[[self getPropertyFromDictionary:imageDictionary forKey:@"width"] floatValue]];
				image.height = [NSNumber numberWithFloat:[[self getPropertyFromDictionary:imageDictionary forKey:@"height"] floatValue]];
				image.type = @"thumb";
				[event addImagesObject:image];
			}
						
			[[EventSyncOperationManager sharedSyncOperationManager] saveContext:&error];
			if (error) {
				// TODO: error handling
			}
		}
    }];
}


#pragma mark - Private Methods

- (id)getPropertyFromDictionary:(NSDictionary*)dictionary forKey:(NSString*)key
{
	id value = [dictionary objectForKey:key];
	if (![value isKindOfClass:[NSNull class]]) {
		return value;
	}
	
	return nil;
}

@end

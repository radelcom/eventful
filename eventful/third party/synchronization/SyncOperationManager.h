//
//  SyncOperationManager.h
//  radelcom
//
//  Created by Jeffrey Leo Oloresisimo on 2013-05-10.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SyncOperation.h"


@interface SyncOperationManager : NSObject {
	NSURL*                          _url;
	NSMutableDictionary*			_operations;
	BOOL							_allowInvalidCerts;
	
	// core data classes
	NSMutableDictionary*            _fetchedResultsControllers;
	NSManagedObjectContext*         _managedObjectContext;
	NSManagedObjectModel*           _managedObjectModel;
	NSPersistentStoreCoordinator*   _persistentStoreCoordinator;
}


@property (nonatomic, copy) NSURL* url;
@property (nonatomic) BOOL allowInvalidCerts;


+ (id)sharedSyncOperationManager;

- (void)addOperation:(SyncOperation*)operation;
- (void)removeOperation:(SyncOperation*)operation;

@end



@interface SyncOperationManager (CoreData)

- (NSString*)coreDataName;
- (NSFetchedResultsController *)fetchedResultsControllerForEntityName:(NSString*)entityName sortDescriptors:(NSArray*)sortDescriptors predicate:(NSPredicate*)predicate;
- (NSManagedObjectContext*)managedObjectContext;
- (id)managedObjectWithName:(NSString*)name predicate:(NSPredicate*)predicate error:(NSError**)error;
- (void)saveContext:(NSError**)error;

@end
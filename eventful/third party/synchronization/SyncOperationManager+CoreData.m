//
//  SyncOperationManager+CoreData.m
//  radelcom
//
//  Created by Jeffrey Leo Oloresisimo on 2013-05-10.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import "SyncOperationManager.h"



@interface SyncOperationManager (Private)

- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end



@implementation SyncOperationManager (CoreData)


#pragma mark - Core Data stack

- (NSString *)coreDataName
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"SUBCLASS SHOULD IMPLEMENT THIS" userInfo:nil];
}

- (id)managedObjectWithName:(NSString*)name predicate:(NSPredicate*)predicate error:(NSError**)error
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
    fetchRequest.entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    
    return [[self.managedObjectContext executeFetchRequest:fetchRequest error:error] lastObject];
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntityName:(NSString*)entityName sortDescriptors:(NSArray*)sortDescriptors predicate:(NSPredicate*)predicate
{
    NSFetchedResultsController* fetchedResultsController = [_fetchedResultsControllers objectForKey:entityName];
	
	if (fetchedResultsController == nil) {
		// Set up the fetched results controller.
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		fetchRequest.sortDescriptors = sortDescriptors;
		fetchRequest.predicate = predicate;
		fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
		[_fetchedResultsControllers setObject:fetchedResultsController forKey:entityName];
	}
    
    return fetchedResultsController;
}

- (void)saveContext:(NSError**)error
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    static NSManagedObjectContext* managedObjectContext = nil;
	
    if (managedObjectContext != nil)
        return managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    static NSManagedObjectModel* managedObjectModel = nil;
	
    if (managedObjectModel != nil)
        return managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.coreDataName withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static NSPersistentStoreCoordinator* persistentStoreCoordinator = nil;
	
    if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.coreDataName]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
	NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
															   forKey:NSFileProtectionKey];
	if(![[NSFileManager defaultManager] setAttributes:fileAttributes
										 ofItemAtPath:[storeURL path] error: &error]) {
		NSLog(@"Unresolved error with store encryption %@, %@",
			  error, [error userInfo]);
		abort();
	}
	
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

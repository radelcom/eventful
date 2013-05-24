//
//  CoreDataTableViewController.h
//  radelcom
//
//  Created by Jeffrey Oloresisimo on 4/23/13.
//  Copyright (c) 2013 radelcom. All rights reserved.
//

#import "SyncOperationManager.h"

@protocol CoreDataTableViewController <NSObject>

@property (nonatomic, strong, readonly) NSManagedObjectContext*	managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController*	fetchedResultsController;

@required
- (NSString*)cellIdentifier;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@interface CoreDataTableViewController : UITableViewController <CoreDataTableViewController, NSFetchedResultsControllerDelegate>
{
	NSManagedObjectContext*			_managedObjectContext;
	NSFetchedResultsController*		_fetchedResultsController;
}

@end

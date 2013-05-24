//
//  EventsListViewController.m
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "EventsListViewController.h"
#import "EventSyncOperationManager.h"
#import "EventTableViewCell.h"

#import "Event.h"
#import "Venue.h"
#import "Image.h"
#import "Participant.h"



@interface EventsListViewController ()

@end

@implementation EventsListViewController {
	ImageLoader*		_imageLoader;
	NSDateFormatter*	_dateFormatter;
	NSUInteger			_currentResultPageNumber;
}


@synthesize currentEventParameter = _currentEventParameter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	_imageLoader = [[ImageLoader alloc] init];
	_imageLoader.delegate = self;
	
	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setDateFormat:@"MM/dd/yyyy, EEEE"];
	
	_currentResultPageNumber = 1;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// clear data before closing
	for (NSManagedObject* object in self.fetchedResultsController.fetchedObjects) {
		[self.managedObjectContext deleteObject:object];
	}
	[self.managedObjectContext save:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (!_fetchedResultsController) {
		NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginDate" ascending:NO];

		_fetchedResultsController = [[EventSyncOperationManager sharedSyncOperationManager] fetchedResultsControllerForEntityName:@"Event"
																													  sortDescriptors:@[sortDescriptor]
																															predicate:nil];
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController performFetch:nil];
	}
	
	return _fetchedResultsController;
}

- (NSManagedObjectContext *)managedObjectContext
{
	if (!_managedObjectContext) {
		_managedObjectContext = [[EventSyncOperationManager sharedSyncOperationManager] managedObjectContext];
	}
	
	return _managedObjectContext;
}

- (NSString *)cellIdentifier
{
	static NSString *CellIdentifier = @"EventTableViewCell";
	return CellIdentifier;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Event* event = [_fetchedResultsController objectAtIndexPath:indexPath];
	EventTableViewCell* eventCell = (EventTableViewCell*)cell;
	
	eventCell.eventImageView.image = nil;
	for (Image* image in event.images) {
		if ([image.type isEqualToString:@"thumb"]) {
			UIImage* cachedImage = [_imageLoader cachedImageForUrl:image.url];
			if (cachedImage) {
				eventCell.eventImageView.image = cachedImage;
			} else {
				[_imageLoader addRequest:image.url forKey:indexPath cache:ImageLoaderCachingPolicyInMemory];
			}
			break;
		}
	}
	
	eventCell.eventTitleLabel.text = event.title;
	eventCell.eventVenueLabel.text = event.venue.name;
	eventCell.eventDateLabel.text = [_dateFormatter stringFromDate:event.beginDate];
	
	NSMutableString* participants = [NSMutableString string];
	for (Participant* participant in event.participants) {
		[participants appendFormat:@"%@, ", participant.name];
	}
	eventCell.eventArtistTeamsLabel.text = participants;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        NSLog(@"Scroll End Called: fetch more data in page %d", ++_currentResultPageNumber);
        NSString* newEventParameters = [NSString stringWithFormat:@"%@&page_number=%d", _currentEventParameter, _currentResultPageNumber];
		[[EventSyncOperationManager sharedSyncOperationManager] getEventsWithParameter:newEventParameters];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_imageLoader removeRequestForKey:indexPath];
}


#pragma mark - ImageLoaderDelegate
- (void)imageLoader:(ImageLoader *)imageLoader didFinishLoadingImage:(UIImage *)image forKey:(id)key
{
	NSIndexPath* indexPath = (NSIndexPath*)key;
	EventTableViewCell* cell = (EventTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
	if (cell) {
		cell.eventImageView.image = image;
	}
}

- (void)imageLoader:(ImageLoader *)imageLoader didCancelLoadingForKey:(id)key
{
	
}

@end

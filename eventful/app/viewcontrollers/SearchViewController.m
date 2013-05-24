//
//  SearchViewController.m
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "SearchViewController.h"
#import "EventsListViewController.h"

#import "EventSyncOperation.h"
#import "EventSyncOperationManager.h"


@interface SearchViewController ()

- (void)setDate:(id)sender;
- (void)nextResponder:(id)sender;
- (void)done:(id)sender;
- (BOOL)validateEntries;

@end

@implementation SearchViewController {
	NSDateFormatter*	_dateFormatter;
	NSString*			_longitude;
	NSString*			_latitude;
}

@synthesize addressTextField = _addressTextField;
@synthesize radiusTextField = _radiusTextField;
@synthesize startDateTextField = _startDateTextField;
@synthesize endDateTextField = _endDateTextField;
@synthesize categoryTextField = _categoryTextField;
@synthesize searchButton = _searchButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setDateFormat:@"dd/MM/yyyy"];
	
	_latitude = nil;
	_longitude = nil;
	
	//http://api.eventful.com/json/events/search?where=32.746682,-117.162741&within=25&app_key=TMfdzhF7qPp4sM2C
	[[EventSyncOperationManager sharedSyncOperationManager] setUrl:[NSURL URLWithString:@"http://api.eventful.com/json"]];
	[[EventSyncOperationManager sharedSyncOperationManager] setAppKey:@"TMfdzhF7qPp4sM2C"];
	
	
	NSCalendar *theCalendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
	dayComponent.day = 1;
	
	// set defatults
	_radiusTextField.text = @"1";
	_startDateTextField.text = [_dateFormatter stringFromDate:[NSDate date]];
	_endDateTextField.text = [_dateFormatter stringFromDate:[theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0]];
	_categoryTextField.text = @"Music";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[_dateFormatter setDateFormat:@"dd/MM/yyyy"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchPressed:(id)sender
{
	NSDate* startDate = [_dateFormatter dateFromString:_startDateTextField.text];
	NSDate* endDate = [_dateFormatter dateFromString:_endDateTextField.text];
	
	[_dateFormatter setDateFormat:@"yyyyMMdd"];
	NSMutableString* parameters = [NSMutableString stringWithFormat:@"where=%@,%@&date=%@00-%@00", _latitude, _longitude, [_dateFormatter stringFromDate:startDate], [_dateFormatter stringFromDate:endDate]];
	if ([_radiusTextField.text length]) {
		[parameters appendFormat:@"&units=km&within=%d", [_radiusTextField.text integerValue]];
	}
	if (![_categoryTextField.text isEqualToString:@"None"]) {
		[parameters appendFormat:@"&category=%@", _categoryTextField.text];
	}
	
	[[EventSyncOperationManager sharedSyncOperationManager] getEventsWithParameter:parameters];
	
	[self performSegueWithIdentifier:@"SearchEvents" sender:sender];
	EventsListViewController* viewController = (EventsListViewController*)self.navigationController.visibleViewController;
	viewController.currentEventParameter = parameters;
}

#pragma mark - Private Methods
- (void)setDate:(id)sender
{
	if ([_startDateTextField isFirstResponder]) {
		_startDateTextField.text = [_dateFormatter stringFromDate:[sender date]];
	} else {
		_endDateTextField.text = [_dateFormatter stringFromDate:[sender date]];
	}
}

- (void)nextResponder:(id)sender
{
	if ([_addressTextField isFirstResponder]) {
		[_radiusTextField becomeFirstResponder];
	} else if ([_radiusTextField isFirstResponder]) {
		[_startDateTextField becomeFirstResponder];
	} else if ([_startDateTextField isFirstResponder]) {
		[_endDateTextField becomeFirstResponder];
	} else if ([_endDateTextField isFirstResponder]) {
		[_categoryTextField becomeFirstResponder];
	} else if ([_categoryTextField isFirstResponder]) {
		[_addressTextField becomeFirstResponder];
	}
}

- (void)done:(id)sender
{
	if ([_addressTextField isFirstResponder]) {
		[_addressTextField resignFirstResponder];
	} else if ([_radiusTextField isFirstResponder]) {
		[_radiusTextField resignFirstResponder];
	} else if ([_startDateTextField isFirstResponder]) {
		[_startDateTextField resignFirstResponder];
	} else if ([_endDateTextField isFirstResponder]) {
		[_endDateTextField resignFirstResponder];
	} else if ([_categoryTextField isFirstResponder]) {
		[_categoryTextField resignFirstResponder];
	}
}

- (BOOL)validateEntries
{
	if ([self isValidAddress] &&
		[self isValidRadius] &&
		[self isValidStartDate] &&
		[self isValidEndDate] &&
		[self isValidCategory]) {
		_searchButton.enabled = YES;
	} else {
		_searchButton.enabled = NO;
	}
	
	return _searchButton.enabled;
}

- (BOOL)isValidAddress
{
	if ([_latitude length] &&
		[_longitude length] &&
		[_addressTextField.text length])
		return YES;
	
	return NO;
}

- (BOOL)isValidRadius
{
	if ([_radiusTextField.text length] &&
		([_radiusTextField.text floatValue] < 0.0f || [_radiusTextField.text floatValue] > 300.0f)) 
		return NO;
	
	return YES;
}

- (BOOL)isValidStartDate
{
	if ([_startDateTextField.text length] == 0) 
		return NO;
	
	NSDate* startDate = [_dateFormatter dateFromString:_startDateTextField.text];
	if ([startDate compare:[NSDate date]] == NSOrderedDescending) 
		return NO;

	return YES;
}

- (BOOL)isValidEndDate
{
	if ([_endDateTextField.text length] == 0)
		return NO;
	
	NSDate* endDate = [_dateFormatter dateFromString:_endDateTextField.text];
	if ([endDate compare:[NSDate date]] == NSOrderedAscending)
		return NO;
	
	NSDate* startDate = [_dateFormatter dateFromString:_startDateTextField.text];
	if ([startDate compare:endDate] == NSOrderedDescending)
		return NO;
	
	return YES;
}

- (BOOL)isValidCategory
{
	if ([_categoryTextField.text isEqualToString:@"Music"] ||
		[_categoryTextField.text isEqualToString:@"Sports"] ||
		[_categoryTextField.text isEqualToString:@"Performing Arts"] ||
		[_categoryTextField.text isEqualToString:@"None"]) {
		return YES;
	}
	
	return NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (_startDateTextField == textField) {
		UIDatePicker* datePicker = [[UIDatePicker alloc] init];
		datePicker.datePickerMode = UIDatePickerModeDate;
		datePicker.minimumDate = [NSDate date];
        datePicker.date = [NSDate date];
        [datePicker addTarget:self
                       action:@selector(setDate:)
             forControlEvents:UIControlEventValueChanged];
		textField.inputView = datePicker;
	} else if (_endDateTextField == textField) {
		NSCalendar *theCalendar = [NSCalendar currentCalendar];
		NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
		dayComponent.day = 1;
	
		UIDatePicker* datePicker = [[UIDatePicker alloc] init];
		datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.date = [theCalendar dateByAddingComponents:dayComponent toDate:[_dateFormatter dateFromString:_startDateTextField.text] options:0];
		datePicker.minimumDate = datePicker.date;
		
		dayComponent.day = 28; // prevent user to selct more than 28 days from the minimum date
		datePicker.maximumDate = [theCalendar dateByAddingComponents:dayComponent toDate:datePicker.date options:0];
        [datePicker addTarget:self
                       action:@selector(setDate:)
             forControlEvents:UIControlEventValueChanged];
		textField.inputView = datePicker;
	} else if (_categoryTextField == textField) {
		UIPickerView* pickerView = [[UIPickerView alloc] init];
		pickerView.showsSelectionIndicator = YES;
		pickerView.delegate = self;
		pickerView.dataSource = self;
		textField.inputView = pickerView;
	}
	
	UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar sizeToFit];
    
    NSMutableArray* items = [NSMutableArray array];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextResponder:)];
    [items addObject:barButton];
	
	barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:barButton];
    
    barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    barButton.tag = textField.tag;
    [items addObject:barButton];
    
    [toolbar setItems:items animated:NO];
    
    textField.inputAccessoryView = toolbar;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSString* errorMessage = nil;
	if (_addressTextField == textField)
	{
		HTTPRequest* request = [HTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", _addressTextField.text]]
											 requestMethod:HTTPMethodGET
											   requestData:nil];
		
		if (![request hasNetworkConnection]) {
			// TODO: handle network connection error
			return;
		}
		
		[request performWithResponseHandler:^(NSData* responseData, NSHTTPURLResponse* response, NSError* error){
			if (error) {
				// TODO: handle response error
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Event Search Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				[alertView show];
				return;
			}
			
			NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
			jsonResponse = [[jsonResponse objectForKey:@"results"] lastObject];
			jsonResponse = [[jsonResponse objectForKey:@"geometry"] objectForKey:@"location"];
			_longitude = [NSString stringWithFormat:@"%f", [[jsonResponse objectForKey:@"lng"] floatValue]];
			_latitude = [NSString stringWithFormat:@"%f", [[jsonResponse objectForKey:@"lat"] floatValue]];
			
			if (![self isValidAddress]) {
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Event Search Error" message:@"Invalid address" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				[alertView show];
			}
			[self validateEntries];
		}];
	} else if (_radiusTextField == textField && ![self isValidRadius]) {
		errorMessage = @"Invalid radius";
	} else if (_startDateTextField == textField && ![self isValidStartDate]) {
		errorMessage = @"Invalid start date";
	} else if (_endDateTextField == textField && ![self isValidEndDate]) {
		errorMessage = @"Invalid end date";
	} else if (_categoryTextField == textField && ![self isValidCategory]) {
		errorMessage = @"Invalid category";
	}
	
	if (errorMessage) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Event Search Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alertView show];
	} else {
		[self validateEntries];
	}
	
	
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self nextResponder:textField];
	
	return YES;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	// TODO: do not hard code
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	// TODO: do not hard code
	return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	// TODO: do not hard code
	switch (row) {
		case 0:
			return @"Music";
		case 1:
			return @"Sports";
		case 2:
			return @"Performing Arts";
		default:
			return @"None";
	}
	
	return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// TODO: do not hard code
	switch (row) {
		case 0:
			_categoryTextField.text = @"Music";
			break;
		case 1:
			_categoryTextField.text = @"Sports";
			break;
		case 2:
			_categoryTextField.text = @"Performing Arts";
			break;
		default:
			_categoryTextField.text = @"None";
			break;
	}
	
	[_categoryTextField resignFirstResponder];
}

@end

//
//  eventfulTests.m
//  eventfulTests
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import "eventfulTests.h"



@implementation eventfulTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setDateFormat:@"dd/MM/yyyy"];
	
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    _searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [_searchViewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}


#pragma mark - Address
- (void)testAddress
{
	// TODO: need to simulate some web service call
	_searchViewController.addressTextField.text = @"some address";
	STAssertTrue(![_searchViewController isValidAddress], @"error invalid address");
}

- (void)testEmptyAddress
{
	_searchViewController.addressTextField.text = nil;
	STAssertTrue(![_searchViewController isValidAddress], @"error invalid address");
}


#pragma mark - Radius
- (void)testRadius
{
	_searchViewController.radiusTextField.text = @"1";
	STAssertTrue([_searchViewController isValidRadius], @"error invalid radius");
}

- (void)testEmptyRadius
{
	_searchViewController.radiusTextField.text = nil;
	STAssertTrue([_searchViewController isValidRadius], @"error invalid radius");
}

- (void)testHigherRadius
{
	_searchViewController.radiusTextField.text = @"301";
	STAssertTrue(![_searchViewController isValidRadius], @"error invalid radius");
}

- (void)testLowerRadius
{
	_searchViewController.radiusTextField.text = @"-1";
	STAssertTrue(![_searchViewController isValidRadius], @"error invalid radius");
}

#pragma mark - Start Date
- (void)testStartDate
{
	_searchViewController.startDateTextField.text = [_dateFormatter stringFromDate:[NSDate date]];
	STAssertTrue([_searchViewController isValidStartDate], @"error invalid start date");
}

- (void)testEmptyStartDate
{
	_searchViewController.startDateTextField.text = nil;
	STAssertTrue([_searchViewController isValidRadius], @"error invalid start date");
}

- (void)testYesterdayStartDate
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[NSDate date]];

	[components setHour:-24];
	NSDate *yesterday = [cal dateByAddingComponents:components toDate:[NSDate date] options:0];

	_searchViewController.startDateTextField.text = [_dateFormatter stringFromDate:yesterday];
	STAssertTrue([_searchViewController isValidRadius], @"error invalid start date");
}

#pragma mark - End Date
- (void)testEndDate
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[NSDate date]];
	
	[components setHour:+24];
	NSDate *tmr = [cal dateByAddingComponents:components toDate:[NSDate date] options:0];
	
	_searchViewController.endDateTextField.text = [_dateFormatter stringFromDate:tmr];
	STAssertTrue([_searchViewController isValidEndDate], @"error invalid end date");
}

- (void)testEmptyEndDate
{
	_searchViewController.endDateTextField.text = nil;
	STAssertTrue(![_searchViewController isValidEndDate], @"error invalid end date");
}

- (void)testStartDateEndDate
{
	NSDate* startingDate = [NSDate date];
	_searchViewController.startDateTextField.text = [_dateFormatter stringFromDate:startingDate];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:startingDate];
	
	[components setDay:+28];
	NSDate *endDate = [cal dateByAddingComponents:components toDate:startingDate options:0];
	
	_searchViewController.endDateTextField.text = [_dateFormatter stringFromDate:endDate];
	STAssertTrue([_searchViewController isValidEndDate], @"error invalid end date");
}

- (void)testInvalidStartDateEndDate
{
	NSDate* startingDate = [NSDate date];
	_searchViewController.startDateTextField.text = [_dateFormatter stringFromDate:startingDate];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:startingDate];
	
	[components setDay:+29];
	NSDate *endDate = [cal dateByAddingComponents:components toDate:startingDate options:0];
	
	_searchViewController.endDateTextField.text = [_dateFormatter stringFromDate:endDate];
	STAssertTrue([_searchViewController isValidEndDate], @"error invalid end date");
}

- (void)testDescendingStartDateEndDate
{
	NSDate* startingDate = [NSDate date];

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:startingDate];
	
	[components setDay:+28];
	NSDate *endDate = [cal dateByAddingComponents:components toDate:startingDate options:0];
	
	_searchViewController.startDateTextField.text = [_dateFormatter stringFromDate:endDate];
	_searchViewController.endDateTextField.text = [_dateFormatter stringFromDate:startingDate];
	STAssertTrue([_searchViewController isValidEndDate], @"error invalid end date");
}


#pragma mark - Category
- (void)testCategory
{
	_searchViewController.categoryTextField.text = @"Music";
	STAssertTrue([_searchViewController isValidCategory], @"error invalid category");
}

- (void)testEmptyCategory
{
	_searchViewController.categoryTextField.text = nil;
	STAssertTrue(![_searchViewController isValidCategory], @"error invalid category");
}

@end

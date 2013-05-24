//
//  SearchViewController.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/12/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
	UITextField*	_addressTextField;
	UITextField*	_radiusTextField;
	UITextField*	_startDateTextField;
	UITextField*	_endDateTextField;
	UITextField*	_categoryTextField;
	
	UIButton*		_searchButton;
}


@property (nonatomic, readonly, strong) IBOutlet UITextField* addressTextField;
@property (nonatomic, readonly, strong) IBOutlet UITextField* radiusTextField;
@property (nonatomic, readonly, strong) IBOutlet UITextField* startDateTextField;
@property (nonatomic, readonly, strong) IBOutlet UITextField* endDateTextField;
@property (nonatomic, readonly, strong) IBOutlet UITextField* categoryTextField;
@property (nonatomic, readonly, strong) IBOutlet UIButton* searchButton;


- (IBAction)searchPressed:(id)sender;

- (BOOL)isValidAddress;
- (BOOL)isValidRadius;
- (BOOL)isValidStartDate;
- (BOOL)isValidEndDate;
- (BOOL)isValidCategory;

@end

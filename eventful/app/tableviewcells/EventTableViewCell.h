//
//  EventTableViewCell.h
//  eventful
//
//  Created by Jeffrey Oloresisimo on 5/13/13.
//  Copyright (c) 2013 Jeffrey Oloresisimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
{
	UIImageView*	_eventImageView;
	UILabel*		_eventTitleLabel;
	UILabel*		_eventVenueLabel;
	UILabel*		_eventDateLabel;
	UILabel*		_eventArtistTeamsLabel;
}

@property (nonatomic, readonly, strong) IBOutlet UIImageView* eventImageView;
@property (nonatomic, readonly, strong) IBOutlet UILabel* eventTitleLabel;
@property (nonatomic, readonly, strong) IBOutlet UILabel* eventVenueLabel;
@property (nonatomic, readonly, strong) IBOutlet UILabel* eventDateLabel;
@property (nonatomic, readonly, strong) IBOutlet UILabel* eventArtistTeamsLabel;

@end

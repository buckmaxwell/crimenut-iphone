//
//  FeedCell.h
//  Crime Nut
//
//  Created by Allen White on 3/20/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *crimeTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *crimeSubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *crimeDescLabel;
@property (strong, nonatomic) IBOutlet UILabel *crimeTimeLabel;

@end

//
//  PerpatratorDescriptionViewController.h
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perpatrator.h"

@class PropertyDescriptionViewController;

@protocol PerpatratorDescriptionViewController <NSObject>
- (void)finishedPerp:(Perpatrator *)perp;
@end


@interface PerpatratorDescriptionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *raceSegmentedControl;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (nonatomic, weak) id <PerpatratorDescriptionViewController> delegate;

@end

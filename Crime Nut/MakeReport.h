//
//  MakeReport.h
//  Crime Nut
//
//  Created by Allen White on 3/19/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OffensesTableViewController.h"
#import "PropertyDescriptionViewController.h"
#import "PerpatratorDescriptionViewController.h"

@interface MakeReport : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, OffensesTableViewController, PropertyDescriptionViewController, PerpatratorDescriptionViewController>
@property (strong, nonatomic) IBOutlet UITextField *whereTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
- (IBAction)postButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *propertyLabel;
@property (strong, nonatomic) IBOutlet UILabel *perpLabel;


@end

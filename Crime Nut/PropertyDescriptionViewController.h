//
//  PropertyDescriptionViewController.h
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Property.h"

@class PropertyDescriptionViewController;

@protocol PropertyDescriptionViewController <NSObject>
- (void)finishedProperty:(Property *)prop;
@end

@interface PropertyDescriptionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *propertyTypeLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextField *modelTextField;
@property (strong, nonatomic) IBOutlet UITextField *manufacturerTextField;
@property (strong, nonatomic) IBOutlet UITextField *valueTextField;

@property (nonatomic, weak) id <PropertyDescriptionViewController> delegate;


@end

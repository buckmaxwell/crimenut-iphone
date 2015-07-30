//
//  OffensesTableViewController.h
//  Crimenut
//
//  Created by Allen White on 7/29/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OffensesTableViewController;

@protocol OffensesTableViewController <NSObject>
- (void)pickedOffense:(NSString *)offense withSubjectCode:(NSString *)code;
@end

@interface OffensesTableViewController : UITableViewController

@property NSArray *offenses;
@property NSArray *subjectCodes;
@property (nonatomic, weak) id <OffensesTableViewController> delegate;

@end

//
//  BasicModel.m
//  Crimenut
//
//  Created by Allen White on 7/29/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "BasicModel.h"

@implementation BasicModel


-(void)fixSeparators:(UITableViewCell *)cell{
	// Remove seperator inset
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	// Prevent the cell from inheriting the Table View's margin settings
	if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
	// Explictly set your cell's layout margins
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	[cell setNeedsUpdateConstraints];
	[cell updateConstraintsIfNeeded];
}


-(void)showAlert:(NSString *)title withMessage:(NSString *)message{
	UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:title
							   message:message
							  delegate:self
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
	[theAlert show];
}


@end

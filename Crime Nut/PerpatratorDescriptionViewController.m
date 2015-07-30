//
//  PerpatratorDescriptionViewController.m
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "PerpatratorDescriptionViewController.h"
#import "BasicModel.h"

@interface PerpatratorDescriptionViewController ()

@end

@implementation PerpatratorDescriptionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.navigationController.navigationBar
		setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	self.navigationItem.title = @"Describe the Suspect";
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(passDataBackToParentView)];
	self.navigationItem.rightBarButtonItem = done;
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


-(void)passDataBackToParentView
{
	if (self.ageTextField.text && self.ageTextField.text.length > 0
	    && self.descriptionTextView.text && self.descriptionTextView.text.length > 0) {
		Perpatrator *perp = [[Perpatrator alloc] init];
		perp.age = self.ageTextField.text;
		perp.perpDescription = self.descriptionTextView.text;
		perp.gender = [self.genderSegmentedControl titleForSegmentAtIndex:self.genderSegmentedControl.selectedSegmentIndex];
		perp.race = [self.raceSegmentedControl titleForSegmentAtIndex:self.raceSegmentedControl.selectedSegmentIndex];
		
		[self.delegate finishedPerp:perp];
		[self.navigationController popViewControllerAnimated:YES];
	}else{
		[[BasicModel new] showAlert:@"Incomplete" withMessage:@"We need more information to continue"];
	}
}


@end

//
//  PropertyDescriptionViewController.m
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "PropertyDescriptionViewController.h"
#import "BasicModel.h"

@interface PropertyDescriptionViewController ()

@end

@implementation PropertyDescriptionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.navigationController.navigationBar
		setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	self.navigationItem.title = @"Missing Property";
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(passDataBackToParentView)];
	self.navigationItem.rightBarButtonItem = done;
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePropertyType)];
	[self.propertyTypeLabel setUserInteractionEnabled:YES];
	[self.propertyTypeLabel addGestureRecognizer:singleTap2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)choosePropertyType{
	self.propertyTypeLabel.text = @"Something";
}

-(void)passDataBackToParentView
{
	if (self.propertyTypeLabel.text && self.propertyTypeLabel.text.length > 0
	    && self.descriptionTextView.text && self.descriptionTextView.text.length > 0
	    && self.valueTextField.text && self.valueTextField.text.length > 0) {
		Property *prop = [[Property alloc] init];
		prop.code = @"#######################################################################################################";
		prop.propertyDescription = self.descriptionTextView.text;
		prop.model = self.modelTextField.text;
		prop.manufacturer = self.manufacturerTextField.text;
		prop.value = self.valueTextField.text;
		[self.delegate finishedProperty:prop];
		[self.navigationController popViewControllerAnimated:YES];
	}else{
		[[BasicModel new] showAlert:@"Incomplete" withMessage:@"We need more information to continue"];
	}
}


@end

//
//  MakeReport.m
//  Crime Nut
//
//  Created by Allen White on 3/19/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "MakeReport.h"
#import "CrimeFeed.h"
#import "BasicModel.h"
#import "OffensesTableViewController.h"
#import "Property.h"



@interface MakeReport () <CLLocationManagerDelegate>
@property NSArray *pickerData;
@property NSArray *subjectCodes;
@property NSString *chosenSubjectCode;
@property NSMutableArray *propertyList;
@property NSMutableArray *perpList;
@end

@implementation MakeReport

@synthesize whereTextField;
@synthesize subjectLabel;
@synthesize descriptionTextField;
@synthesize dateButton;


CLLocationManager *locationManager;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	self.navigationItem.title = @"Report an Incident";
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickOffense)];
	self.subjectLabel.text = @"Choose Offense ->";
	[self.subjectLabel setUserInteractionEnabled:YES];
	[self.subjectLabel addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(describeProperty)];
	[self.propertyLabel setUserInteractionEnabled:YES];
	[self.propertyLabel addGestureRecognizer:singleTap2];
	
	UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(describePerp)];
	[self.perpLabel setUserInteractionEnabled:YES];
	[self.perpLabel addGestureRecognizer:singleTap3];
	
	if ([CLLocationManager locationServicesEnabled]) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[locationManager requestWhenInUseAuthorization];
		}
		locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
	}else{
		NSLog(@"well no fuckin wonder\n");
	}
	self.pickerData = @[@"Theft", @"Property Damage", @"Burglary",@"Assault",@"Menacing", @"Vandalism",@"Robbery",@"Other"];
	self.subjectCodes = @[@"115",          @"551",                   @"6969",          @"254",           @"255",       @"554",        @"450",        @"0000"];
	self.propertyList = [NSMutableArray new];
	self.perpList = [NSMutableArray new];
	[self updateDateLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateDateLabel{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"MM/dd/yyyy hh:mma";
	NSString *date = [formatter stringFromDate:[NSDate date]];
	dateButton.titleLabel.text = date;
	[dateButton setTitle:date forState:UIControlStateNormal];
}


-(void)pickOffense{
	OffensesTableViewController *otvc = [self.storyboard instantiateViewControllerWithIdentifier:@"OffensesTableViewController"];
	otvc.offenses = self.pickerData;
	otvc.subjectCodes = self.subjectCodes;
	otvc.delegate = self;
	[self.navigationController pushViewController:otvc animated:YES];
}

- (void)pickedOffense:(NSString *)offense withSubjectCode:(NSString *)code{
	self.subjectLabel.text = offense;
	self.chosenSubjectCode = code;
}


-(void)describeProperty{
	PropertyDescriptionViewController *pdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PropertyDescriptionViewController"];
	pdvc.delegate = self;
	[self.navigationController pushViewController:pdvc animated:YES];
}

- (void)finishedProperty:(Property *)property{
	[self.propertyList addObject:property];
	self.propertyLabel.text = [NSString stringWithFormat:@"%lu piece of property cited", (unsigned long)self.propertyList.count];
}



-(void)describePerp{
	PerpatratorDescriptionViewController *pdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PerpatratorDescriptionViewController"];
	pdvc.delegate = self;
	[self.navigationController pushViewController:pdvc animated:YES];
}

- (void)finishedPerp:(Perpatrator *)perp{
	[self.perpList addObject:perp];
	self.perpLabel.text = [NSString stringWithFormat:@"%lu suspect cited", (unsigned long)self.perpList.count];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}




- (IBAction)postButtonTapped:(id)sender {
	NSString *where = whereTextField.text;
	NSString *time = dateButton.titleLabel.text;
	NSString *what = subjectLabel.text;
	NSString *desc = descriptionTextField.text;
	
	
	if( [what isEqualToString:@""] || [desc isEqualToString:@""] || [where isEqualToString:@""] ){
		[[BasicModel new] showAlert:@"Hmmmm..." withMessage:@"Some report information is mising"];
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tokenfromstorage = [defaults stringForKey:@"token"];
	NSNumber *latitude = [NSNumber numberWithFloat:locationManager.location.coordinate.latitude];
	NSNumber *longitude = [NSNumber numberWithFloat:locationManager.location.coordinate.longitude];
	NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/new"];
	NSArray *empty = @[];
	NSDictionary *dictionary = @{
				     @"token":tokenfromstorage,
				     @"subjectcode":what,
				     @"address_line1":where,
								 @"time_began": time,
								 @"time_ended":time,
				     @"lat_reported_from":latitude.stringValue,
				     @"lon_reported_from":longitude.stringValue,
				     @"description":desc,
				     @"offenses":empty,
				     @"perpetrators":empty,
				     @"property":empty
				     };

	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
	BasicModel *model = [BasicModel new];
	[model callAPI:url withJSONData:JSONData withCompletionBlock:^(NSDictionary *data) {
		if (data) {
			//get and store token
			NSString *idfromJson = [data objectForKey:@"id"];
			NSLog(@"ID: %@",idfromJson);
			if(idfromJson){
				//send em to the main screen
				CrimeFeed *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CrimeFeed"];
				UINavigationController *navigationController =
				[[UINavigationController alloc] initWithRootViewController:controller];
				
				//now present this navigation controller modally
				[self presentViewController:navigationController
							animated:YES
							completion:^{
							}];
			}else{
				[[BasicModel new] showAlert:@"Something went amiss" withMessage:@"For some reason we couldnt process your report.\nSorry about that."];
			}
		}
	} andErrorResponseBlock:^(NSMutableArray *apiresponse){
		[model showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
	}];
}




-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [locationManager stopUpdatingLocation];
}



- (void)changeDate:(UIDatePicker *)sender {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"MM/dd/yyyy hh:mma";
	NSString *date = [formatter stringFromDate:sender.date];
	dateButton.titleLabel.text = date;
	[dateButton setTitle:date forState:UIControlStateNormal];
}


- (void)removeViews:(id)object {
	[[self.view viewWithTag:9] removeFromSuperview];
	[[self.view viewWithTag:10] removeFromSuperview];
	[[self.view viewWithTag:11] removeFromSuperview];
}


- (void)dismissDatePicker:(id)sender {
	CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44);
	CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44,  self.view.bounds.size.width, 216);
	[UIView beginAnimations:@"MoveOut" context:nil];
	[self.view viewWithTag:9].alpha = 0;
	[self.view viewWithTag:10].frame = datePickerTargetFrame;
	[self.view viewWithTag:11].frame = toolbarTargetFrame;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeViews:)];
	[UIView commitAnimations];
}

- (IBAction)callDP:(id)sender {
	if ([self.view viewWithTag:9]) {
		return;
	}
	CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, self.view.bounds.size.width, 44);
	CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, self.view.bounds.size.width, 216);
	
	UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
	darkView.alpha = 0;
	darkView.backgroundColor = [UIColor blackColor];
	darkView.tag = 9;
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
	[darkView addGestureRecognizer:tapGesture];
	[self.view addSubview:darkView];
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, self.view.bounds.size.width, 216)];
	datePicker.tag = 10;
	datePicker.backgroundColor = [UIColor whiteColor];
	[datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:datePicker];
	
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
	toolBar.tag = 11;
	toolBar.barStyle = UIBarStyleDefault;
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
	doneButton.tintColor = [UIColor blackColor];
	[toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
	[self.view addSubview:toolBar];
	
	[UIView beginAnimations:@"MoveIn" context:nil];
	toolBar.frame = toolbarTargetFrame;
	datePicker.frame = datePickerTargetFrame;
	darkView.alpha = 0.9;
	[UIView commitAnimations];
}


@end

//
//  ViewReport.m
//  Crime Nut
//
//  Created by Allen White on 3/20/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "ViewReport.h"
#import "BasicModel.h"

#define METERS_MILE 1609.344
#define METERS_FEET 3.28084

@interface ViewReport ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *reportComments;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) UIScrollView *handledScrollView;

@end

@implementation ViewReport

@synthesize reportId;
@synthesize commentTextField;
@synthesize commentsLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.descriptionLabel.text = @"";
    [[self mapView] setShowsUserLocation:YES];
	//NSLog(@"id1%@",reportId);

	//register this view to display on notification
	///////////////////////////////////
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationEnteredForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//get lat, lon, desc, comments
-(void)viewWillAppear:(BOOL)animated{
	//load the report
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tokenfromstorage = [defaults stringForKey:@"token"];
	
	NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/report"];
	NSDictionary *dictionary = @{@"reportid":self.reportId, @"token":tokenfromstorage};
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
	BasicModel *model = [BasicModel new];
	[model callAPI:url withJSONData:JSONData withCompletionBlock:^(NSDictionary *data) {
		if (data) {
			//shit worked
			NSString *desc = [data objectForKey:@"description"];
			NSString *lon = [data objectForKey:@"lon"];
			NSString *lat = [data objectForKey:@"lat"];
			CLLocation *loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
			
			[self showDescription:desc];
			NSMutableArray * annotationsToRemove = [ self.mapView.annotations mutableCopy ] ;
			[ annotationsToRemove removeObject:self.mapView.userLocation ] ;
			[ self.mapView removeAnnotations:annotationsToRemove ] ;
			// zoom the map into the users current location
			MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate, METERS_MILE, METERS_MILE);
			[[self mapView] setRegion:viewRegion animated:YES];
				
			MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
			[annotation setCoordinate:loc.coordinate];
			[self.mapView addAnnotation:annotation];
				
			self.reportComments =  [data objectForKey:@"comments"];
			[self getComments];
		}
	} andErrorResponseBlock:^(NSMutableArray *apiresponse){
		[model showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
	}];
}



 
//display alert for confirmation
- (IBAction)spamButtonTapped:(id)sender {
    //alert user ~ ok or cancel
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"One sec!"
                                                       message:@"You are about to report this as spam. Are you sure?"
                                                      delegate:self
                                             cancelButtonTitle:@"This is spam"
                                             otherButtonTitles:@"Cancel",nil];
    [theAlert show];
}


//resize the title
-(void)showTitle:(NSString *)title{
//	self.subjectLabel.text = [NSString stringWithFormat:@"\n%@\n\n ",description];
	self.subjectLabel.numberOfLines = 0;
	[self.subjectLabel setPreferredMaxLayoutWidth:360];
	CGSize maxSize = CGSizeMake(360, 910);
	CGRect expectedLabelSize = [self.subjectLabel.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.subjectLabel.font} context:Nil];
	CGRect newFrame = self.subjectLabel.frame;
	newFrame.size.height = expectedLabelSize.size.height;
	
	self.subjectLabel.frame = newFrame;
	
}

//get comments and resize the box they sit in
- (void) getComments{
    NSString *comment = @"";
    commentsLabel.numberOfLines = 0;
    for (int i = 0; i < self.reportComments.count; i++) {
        comment = [NSString stringWithFormat:@"%@\n%@\n ",
                   comment,
                   [[self.reportComments objectAtIndex:i] objectForKey:@"content"]];
    }
    commentsLabel.text = comment;
   
    [commentsLabel setPreferredMaxLayoutWidth:360];
    CGSize maxSize = CGSizeMake(360, 810);
    CGRect expectedLabelSize = [comment boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:commentsLabel.font} context:Nil];
    CGRect newFrame = commentsLabel.frame;
    newFrame.size.height = expectedLabelSize.size.height;
    commentsLabel.frame = newFrame;

}

//set description and resize the box its in
-(void)showDescription:(NSString *)description{
	self.descriptionLabel.text = [NSString stringWithFormat:@"\n%@\n",description];
}


//process the spam notification
- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0 && [@"This is spam" isEqualToString:[theAlert buttonTitleAtIndex:buttonIndex]]){
		//send the ol request for spam
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *tokenfromstorage = [defaults stringForKey:@"token"];
		
		NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/spam/new"];
		NSDictionary *dictionary = @{@"reportid":self.reportId, @"token":tokenfromstorage};
		NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
		BasicModel *model = [BasicModel new];
		[model callAPI:url withJSONData:JSONData withCompletionBlock:^(NSDictionary *data) {
			if (data) {
				[[BasicModel new] showAlert:@"Thanks!" withMessage:@"This post now has a lower priority than others."];
			}
		} andErrorResponseBlock:^(NSMutableArray *apiresponse){
			[model showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
		}];
	}
}




- (IBAction)postCommentTapped:(id)sender {
	//get token
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tokenfromstorage = [defaults stringForKey:@"token"];
	
	NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/comments/new"];
	NSDictionary *dictionary = @{@"report_id":self.reportId, @"token":tokenfromstorage,@"content":self.commentTextField.text};
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
	BasicModel *model = [BasicModel new];
	[model callAPI:url withJSONData:JSONData withCompletionBlock:^(NSDictionary *data) {
		if (data) {
			[[BasicModel new] showAlert:@"We've posted your comment" withMessage:@"Thanks for being a Crimenut!"];
			
			self.commentsLabel.text = [NSString stringWithFormat:@"%@\n%@\n ",self.commentsLabel.text, self.commentTextField.text];
			[commentsLabel setPreferredMaxLayoutWidth:360];
			CGSize maxSize = CGSizeMake(360, 810);
			CGRect expectedLabelSize = [self.commentTextField.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:commentsLabel.font} context:Nil];
			CGRect newFrame = commentsLabel.frame;
			newFrame.size.height = expectedLabelSize.size.height;
			commentsLabel.frame = newFrame;
			self.commentTextField.text = @"";
		}
	} andErrorResponseBlock:^(NSMutableArray *apiresponse){
		[model showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
	}];
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
	NSLog(@"Application Entered Foreground");
}

@end

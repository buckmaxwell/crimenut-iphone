//
//  CrimeFeed.m
//  Crime Nut
//
//  Created by Allen White on 3/14/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "CrimeFeed.h"
#import "Login.h"
#import "FeedCell.h"
#import "ViewReport.h"
#import "NSDate+NVTimeAgo.h"
#import "BasicModel.h"

@interface CrimeFeed ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *reportPosts;
@property (nonatomic,strong) ViewReport *ViewReport;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, assign) BOOL endOfFeed;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;

@end

@implementation CrimeFeed

CLLocationManager *locationManager;

- (void)viewDidLoad {
	[super viewDidLoad];
	//check if user is logged in
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *token = [defaults stringForKey:@"token"];
	if(!token){
		//1//send they ass back to login bruh
		Login *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
		[self presentViewController:controller animated:YES completion:nil];
	}else{
		UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CrimeNutLogo_034"]]];
		self.navigationItem.leftBarButtonItem = item;
		self.endOfFeed = NO;
		[self.tableView setDataSource:self];
		[self.tableView setDelegate:self];
		self.tableView.rowHeight = UITableViewAutomaticDimension;
		self.tableView.estimatedRowHeight = 60.0;
		self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
		
		self.refreshControl = [[UIRefreshControl alloc] init];
		self.refreshControl.backgroundColor = [UIColor blackColor];
		self.refreshControl.tintColor = [UIColor whiteColor];
		[self.refreshControl addTarget:self action:@selector(getFeedOne) forControlEvents:UIControlEventValueChanged];
		
		self.lat = [NSNumber numberWithFloat:40.0000395];
		self.lon = [NSNumber numberWithFloat:-83.0153724];
		
		if ([CLLocationManager locationServicesEnabled]) {
			locationManager = [[CLLocationManager alloc] init];
			locationManager.delegate = self;
			if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[locationManager requestWhenInUseAuthorization];
		}
		locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
        }
    }
}


-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (self.currentPage) {
		[self getFeed:self.currentPage];
	}else{
		[self getFeedOne];
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        //location denied, handle accordingly
	    self.lat = [NSNumber numberWithFloat:40.0000395];
	    self.lon = [NSNumber numberWithFloat:-83.0153724];
	    [self getFeedOne];
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
	    if (locationManager.location.coordinate.latitude == 0 && locationManager.location.coordinate.longitude == 0) {
		    self.lat = [NSNumber numberWithFloat:40.0000395];
		    self.lon = [NSNumber numberWithFloat:-83.0153724];
	    }else{
		    self.lat = [NSNumber numberWithFloat:locationManager.location.coordinate.latitude];
		    self.lon = [NSNumber numberWithFloat:locationManager.location.coordinate.longitude];
	    }
	    [self getFeedOne];
    }
}


-(void)getFeedOne{
	[self getFeed:[NSNumber numberWithInt:1]];
}


-(void)getFeed:(NSNumber *)page{
	//get token
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *tokenfromstorage = [defaults stringForKey:@"token"];
	NSNumber *latitude = self.lat;
	NSNumber *longitude = self.lon;
	
	NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/feed"];
	NSDictionary *dictionary = @{@"token":tokenfromstorage, @"lon":longitude.stringValue, @"lat":latitude.stringValue,@"page":page};
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
	BasicModel *model = [BasicModel new];
	[model callAPI:url withJSONData:JSONData withCompletionBlock:^(NSDictionary *data) {
		if (data) {
			if(self.reportPosts.count == 0){
				self.reportPosts = [[data objectForKey:@"reports"] mutableCopy];
			}else{
				[self.reportPosts addObjectsFromArray:[[data objectForKey:@"reports"] mutableCopy]];
			}
			NSString *apiresponse = [data objectForKey:@"next_page"];
			if (!apiresponse) {
				self.endOfFeed = YES;
			}
			self.currentPage = page;
			[self.tableView reloadData];
		}
	} andErrorResponseBlock:^(NSMutableArray *apiresponse){
		[model showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
	}];
	if (self.refreshControl) {
		[self.refreshControl endRefreshing];
	}
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [locationManager stopUpdatingLocation];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (self.reportPosts.count > 0) {
		self.tableView.backgroundView = NULL;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		return 1;
	}else{
		// Display a message when the table is empty
		UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
		messageLabel.text = @"No data is currently available. Please pull down to refresh.";
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.numberOfLines = 0;
		messageLabel.textAlignment = NSTextAlignmentCenter;
		messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
		[messageLabel sizeToFit];
		self.tableView.backgroundView = messageLabel;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		return 0;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reportPosts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
	// Configure the cell...
	BasicModel *model = [[BasicModel alloc] init];

	[self configureCell:cell forIndexPath:indexPath];
	
	self.tableView.layer.shouldRasterize = YES;
	self.tableView.layer.rasterizationScale = [UIScreen mainScreen].scale;
	[model fixSeparators:cell];
	
	[cell setNeedsUpdateConstraints];
	[cell updateConstraintsIfNeeded];

	if(!self.endOfFeed){
		if (indexPath.row == [self.reportPosts count] - 1)
		{
			NSNumber *nextpage = [NSNumber numberWithInt:[self.currentPage intValue] + 1];
			[self getFeed:nextpage];
		}
	}
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.ViewReport == nil)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main"
                                                             bundle: nil];
        self.ViewReport = [storyboard instantiateViewControllerWithIdentifier: @"ViewReport"];
        [self.ViewReport view];
    }
    
    NSString *time = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"time_began"];
    if([time isEqualToString:@"None"]){ time = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"time_reported"];}
    if([time isEqualToString:@"None"]){ time = @"";}else{
        
		if ([time rangeOfString:@"."].location != NSNotFound) {
			NSRange range = [time rangeOfString:@"."];
			time = [time substringWithRange:NSMakeRange(0, range.location)];
		}
		
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *myDate = [dateFormatter dateFromString:time];
        
        NSString *timeago = [myDate formattedAsTimeAgo];
        time = timeago;
    }
	NSString *subject = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"subject"];
	
	if ([subject rangeOfString:@"Burglary"].location != NSNotFound) {
		subject = @"Burglary";
	}
	
    NSString *housNum = [NSString stringWithFormat:@"%@ ",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"house_number"]];
    NSString *streetPrefix = [NSString stringWithFormat:@"%@ ",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"street_prefix"]];
    NSString *street = [NSString stringWithFormat:@"%@",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"street"]];
    NSString *streetSuffix = [NSString stringWithFormat:@" %@",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"street_suffix"]];
    if([housNum isEqualToString:@"None "]){ housNum = @"";}
    if([streetPrefix isEqualToString:@"None "]){ streetPrefix = @"";}
    if([street isEqualToString:@"None"]){ street = @"";}
    if([streetSuffix isEqualToString:@" None"]){ streetSuffix = @"";}
    
    NSString *location = [NSString stringWithFormat:@"%@%@%@%@",housNum,streetPrefix,street,streetSuffix];

    self.ViewReport.timeStampLabel.text = time;
    self.ViewReport.subjectLabel.text = subject;
    self.ViewReport.locationLabel.text = location;
    self.ViewReport.reportId = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"id"];
    self.ViewReport.descriptionLabel.text = @"";
    self.ViewReport.commentTextField.text = @"";
    self.ViewReport.commentsLabel.text = @"";
    [self.navigationController pushViewController:self.ViewReport animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)configureCell:(FeedCell *)cell forIndexPath:(NSIndexPath *)indexPath{
	NSString *desc = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"description"];
	NSString *time = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"time_began"];
	NSString *subject = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"subject"];
	
	NSRange lastDashRange = [subject rangeOfString:@"-" options:NSBackwardsSearch];
	if(lastDashRange.location != NSNotFound){
		subject = [subject substringToIndex:lastDashRange.location];
	}
	
	NSString *housNum = [NSString stringWithFormat:@"%@ ",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"house_number"]];
	NSString *streetPrefix = [NSString stringWithFormat:@"%@ ",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"street_prefix"]];
	NSString *street = [NSString stringWithFormat:@"%@",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"street"]];
	NSString *streetSuffix = [NSString stringWithFormat:@" %@",[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"street_suffix"]];
	if([housNum isEqualToString:@"None "]){ housNum = @"";}
	if([streetPrefix isEqualToString:@"None "]){ streetPrefix = @"";}
	if([street isEqualToString:@"None"]){ street = @"";}
	if([streetSuffix isEqualToString:@" None"]){ streetSuffix = @"";}
	 
	if([time isEqualToString:@"None"]){ time = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"time_reported"];}
	if([time isEqualToString:@"None"]){ time = @"";}else{
		if ([time rangeOfString:@"."].location != NSNotFound) {
			NSRange range = [time rangeOfString:@"."];
			time = [time substringWithRange:NSMakeRange(0, range.location)];
		}
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		NSDate *myDate = [dateFormatter dateFromString:time];
	
		NSString *timeago = [myDate formattedAsTimeAgo];
		time = timeago;
	}
	if ([subject rangeOfString:@"Burglary"].location != NSNotFound) {
		subject = @"Burglary";
	}
	NSString *location = [NSString stringWithFormat:@"%@%@%@%@",housNum,streetPrefix,street,streetSuffix];
	
	cell.crimeTimeLabel.text = time;
	cell.crimeTitleLabel.text = subject;
	cell.crimeSubtitleLabel.text = location;
	cell.crimeDescLabel.text = desc;
}

@end

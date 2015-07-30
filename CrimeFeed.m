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

@interface CrimeFeed ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *reportPosts;
@property (nonatomic,strong) ViewReport *ViewReport;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, assign) BOOL endOfFeed;

@end

@implementation CrimeFeed

CLLocationManager *locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    //check if user is logged in
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSLog(@"//1//send they ass back to login bruh\n");
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
        self.tableView.rowHeight = 100;
        //        self.tableView.rowHeight = UITableViewAutomaticDimension;
        // self.tableView.estimatedRowHeight = 160.0;
        
        if ([CLLocationManager locationServicesEnabled]) {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [locationManager requestWhenInUseAuthorization];
                //2//get the location to turn on
                NSLog(@"//2//get the location to turn on\n");
            }
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locationManager startUpdatingLocation];
            NSLog(@"//2.5//get the location to turn on\n");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//3// location services were approved
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"//3// location services were approved\n");
    if (status == kCLAuthorizationStatusDenied) {
        //location denied, handle accordingly
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"//4// get feed//\n");
        [self getFeed:[NSNumber numberWithInt:1]];
        //4// get feed//

    }
    
}


//5// get the posts
-(void)getFeed:(NSNumber *)page{
    
    NSLog(@"//5// get the posts\n");
    
    //get token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenfromstorage = [defaults stringForKey:@"token"];
    
    //get lat and long
    
    NSNumber *latitude = [NSNumber numberWithFloat:locationManager.location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:locationManager.location.coordinate.longitude];
    
    //start the call
    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/feed"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Create a simple dictionary with numbers.
    NSDictionary *dictionary = @{@"token":tokenfromstorage, @"lon":longitude.stringValue, @"lat":latitude.stringValue,@"page":page};
    
    // Convert the dictionary into JSON data.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:nil];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:JSONData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //use this to grab the ol response
    __block NSMutableArray *apiresponse = [NSMutableArray array];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                               NSInteger statusCode = [httpResponse statusCode];
                               if (!connectionError) {
                                   if (statusCode != 500) {
                                       NSError *error = nil;
                                       NSDictionary *responseDictionary = [NSJSONSerialization
                                                                           JSONObjectWithData:data
                                                                           options:0
                                                                           error:&error];
					apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           //TODO: alert user somehow of error?
										   [self showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
                                       }else{
                                           NSIndexPath *myIndex = [NSIndexPath indexPathForRow:self.reportPosts.count inSection:0] ;
                                           if(self.reportPosts.count == 0){
                                               self.reportPosts = [[responseDictionary objectForKey:@"reports"] mutableCopy];
                                           }else{
                                               [self.reportPosts addObjectsFromArray:[[responseDictionary objectForKey:@"reports"] mutableCopy]];
                                           }
                                           apiresponse = [responseDictionary objectForKey:@"next_page"];
                                           if (!apiresponse) {
                                               self.endOfFeed = YES;
                                           }
                                           //6// update the tableview
                                           NSLog(@"//6// update the tableview\n");
                                           [self.tableView cellForRowAtIndexPath:myIndex];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSLog(@"//7// reload data\n");
                                                self.currentPage = page;
                                                [self.tableView reloadData];
                                           });
                                       }
                                   }else{
                                       NSLog(@"STATUS: %ld\n",(long)statusCode);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"Bad connection: %ld",(long)statusCode]];
                                       });
                                   }
                               } else {
                                   NSLog(@"Error!!!! ,%@", [connectionError localizedDescription]);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"There seems to be a problem..." withMessage:[connectionError localizedDescription]];
                                   });
                               }
                           }];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [locationManager stopUpdatingLocation];
}

-(void)showAlert:(NSString *)title withMessage:(NSString *)message{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reportPosts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 140;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
	
	// Configure the cell...
	dispatch_async(dispatch_get_main_queue(), ^{
	// Update the UI
	
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
	
	cell.descLabel.text = desc;
	cell.timeLabel.text = time;
	cell.titleLabel.text = subject;
	cell.subtitleLabel.text = location;
	
	
	if(!self.endOfFeed){
		if (indexPath.row == [self.reportPosts count] - 1)
		{
			NSNumber *nextpage = [NSNumber numberWithInt:[self.currentPage intValue] + 1];
			[self getFeed:nextpage];
			NSLog(@"call was made");
		}
	}
	});
	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.ViewReport == nil)
    {
        NSLog(@"instantiating\n");
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
}


@end

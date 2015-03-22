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

@property (nonatomic, strong) NSArray *reportPosts;
@property (nonatomic,strong) ViewReport *ViewReport;

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
        [self getFeed];
        //4// get feed//

    }
    
}


//5// get the posts
-(void)getFeed{
    
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
    NSDictionary *dictionary = @{@"token":tokenfromstorage, @"lon":longitude.stringValue, @"lat":latitude.stringValue,@"miles":@"200"};
    
    // Convert the dictionary into JSON data.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:nil];
    //    NSString *strData = [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];
    //    NSLog(@"1:::%@\n", strData);
    //    NSLog(@"2:::%@", JSONData);
    // Create a POST request with our JSON as a request body.
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
                                       //NSLog(@"err::: %@\n",error);
                                       //NSLog(@"response::: %@\n",response);
                                       //NSLog(@"RespDict::: %@\n", responseDictionary);
                                       apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           //TODO: alert user somehow of error?
                                       }else{
                                           NSIndexPath *myIndex = [NSIndexPath indexPathForRow:0 inSection:0] ;
                                           self.reportPosts = [responseDictionary objectForKey:@"reports"];
                                           //6// update the tableview
                                           NSLog(@"//6// update the tableview\n");
                                           [self.tableView cellForRowAtIndexPath:myIndex];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSLog(@"//7// reload data\n");
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
    //NSLog(@"height: %f\n", UITableViewAutomaticDimension);
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    // Configure the cell...
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI

        NSString *title = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"title"];
        NSString *subject = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"subject"];
        NSString *time = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"time_began"];
        
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
        
            NSRange range = [time rangeOfString:@"."];
            time = [time substringWithRange:NSMakeRange(0, range.location)];
            
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

        cell.locationLabel.text = location;
        cell.timeLabel.text = time;
        cell.titleLabel.text = title;
        cell.subtitleLabel.text = subject;
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
        
        NSRange range = [time rangeOfString:@"."];
        time = [time substringWithRange:NSMakeRange(0, range.location)];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *myDate = [dateFormatter dateFromString:time];
        
        NSString *timeago = [myDate formattedAsTimeAgo];
        time = timeago;
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

    self.ViewReport.titleLabel.text = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"title"];
    self.ViewReport.timeStampLabel.text = time;
    self.ViewReport.subjectLabel.text =[[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"subject"];
    self.ViewReport.locationLabel.text = location;
    self.ViewReport.reportId = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"id"];
    self.ViewReport.descriptionLabel.text = @"";
    self.ViewReport.commentTextField.text = @"";
    [self.navigationController pushViewController:self.ViewReport animated:YES];
}


@end

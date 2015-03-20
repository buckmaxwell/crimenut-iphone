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

@interface CrimeFeed ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *reportPosts;

@end

@implementation CrimeFeed

CLLocationManager *locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    //NSLog(@"token:::::%@", token);
    
    if(token){
        
    }else{
        NSLog(@"well no fuckin wonder\n");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//// Delegate method
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    CLLocation* loc = [locations lastObject]; // locations is guaranteed to have at least one object
//    float latitude = loc.coordinate.latitude;
//    float longitude = loc.coordinate.longitude;
//}

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

-(void)viewWillAppear:(BOOL)animated{
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
        self.tableView.rowHeight = 80;
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
    NSDictionary *dictionary = @{@"token":tokenfromstorage, @"lon":longitude.stringValue, @"lat":latitude.stringValue};
    
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
//                                               NSLog(@"self.reportPosts=%@\n", self.reportPosts);
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
                                   }
                               } else {
                                   NSLog(@"Error!!!! ,%@", [connectionError localizedDescription]);
                               }
                           }];
    
}



-(void)viewDidDisappear:(BOOL)animated{
    [locationManager stopUpdatingLocation];
}

#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 80;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reportPosts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"height: %f\n", UITableViewAutomaticDimension);
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    // Configure the cell...
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI

        NSString *title = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"title"];
        NSString *subject = [[self.reportPosts objectAtIndex:[indexPath row]] objectForKey:@"subject"];
        cell.titleLabel.text = title;
        cell.subtitleLabel.text = subject;
    });
    return cell;
}


@end

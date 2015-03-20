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

@end

@implementation CrimeFeed

CLLocationManager *locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    //NSLog(@"token:::::%@", token);
    self.tableView.estimatedRowHeight = 160.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if(token){
        
    }else{
        NSLog(@"well no fuckin wonder\n");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Delegate method
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* loc = [locations lastObject]; // locations is guaranteed to have at least one object
    float latitude = loc.coordinate.latitude;
    float longitude = loc.coordinate.longitude;
    NSLog(@"lats:%.8f\n",latitude);
    NSLog(@"lons:%.8f\n",longitude);
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusDenied) {
        //location denied, handle accordingly
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self getFeed];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    //check if user is logged in
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    if(!token){
        //send they ass back to login bruh
        Login *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        
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



-(void)getFeed{
    // Do any additional setup after loading the view.
    
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
                                       NSLog(@"err::: %@\n",error);
                                       NSLog(@"response::: %@\n",response);
                                       NSLog(@"RespDict::: %@\n", responseDictionary);
                                       apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           //TODO: alert user somehow of error?
                                       }else{
                                           //get and store token
                                           //////// NSString *token = [responseDictionary objectForKey:@"token"];
                                           //                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                           //                                                       if(){
                                           //                                                           //send em to the main screen
                                           //                                                           CrimeFeed *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CrimeFeed"];
                                           //                                                           //                                                   [self presentViewController:controller animated:YES completion:nil];
                                           //
                                           //                                                           //                                                   CrimeFeed *controller = [[CrimeFeed alloc] initWithNibName:nil bundle:nil];
                                           //                                                           UINavigationController *navigationController =
                                           //                                                           [[UINavigationController alloc] initWithRootViewController:controller];
                                           //
                                           //                                                           //now present this navigation controller modally
                                           //                                                           [self presentViewController:navigationController
                                           //                                                                              animated:YES
                                           //                                                                            completion:^{
                                           //
                                           //                                                                            }];
                                           //                                                       }else{
                                           //                                                           //TODO: handle storing issues
                                           //                                                       }
                                           //                                                   });
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];

    // Configure the cell...
    [self setTitleForCell:cell atIndex:indexPath];
    [self setSubtitleForCell:cell atIndex:indexPath];
    return cell;
}

-(void)setSubtitleForCell:(FeedCell *)cell atIndex:(NSIndexPath *)indexPath {
    //grab the crime info from the index path
    cell.titleLabel.text = @"Yooo";
    
}

-(void)setTitleForCell:(FeedCell *)cell atIndex:(NSIndexPath *)indexPath {
    cell.subtitleLabel.text = @"what up";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

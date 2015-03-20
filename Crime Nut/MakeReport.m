//
//  MakeReport.m
//  Crime Nut
//
//  Created by Allen White on 3/19/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "MakeReport.h"
#import "CrimeFeed.h"

@interface MakeReport () <CLLocationManagerDelegate>{
    NSArray *pickerData;
    NSArray *subjectCodes;
}@end

@implementation MakeReport

@synthesize titleTextField;
@synthesize whereTextField;
@synthesize whenTextField;
//@synthesize whatHappenedTextField;
@synthesize subjectPicker;
@synthesize descriptionTextField;

CLLocationManager *locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    pickerData = @[@"Theft", @"Criminal Damaging", @"Burglary",@"Assault",@"Menacing", @"Vandalism",@"Robbery",@"Other"];
    subjectCodes = @[@"115",          @"551",                   @"6969",          @"254",           @"255",               @"554",               @"450",           @"0000"];
    subjectPicker.dataSource = self;
    subjectPicker.delegate = self;
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

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return (int)1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData[row];
}

- (IBAction)postButtonTapped:(id)sender {
    NSString *title =titleTextField.text;
    NSString *where = whereTextField.text;
    NSString *when = whenTextField.text;
    NSString *what = [subjectCodes objectAtIndex:[subjectPicker selectedRowInComponent:0]];
    NSString *desc = descriptionTextField.text;
    
    //get token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenfromstorage = [defaults stringForKey:@"token"];

    //get lat and long

    NSNumber *latitude = [NSNumber numberWithFloat:locationManager.location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:locationManager.location.coordinate.longitude];
    
    // URL of the endpoint we're going to contact.
    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/new"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSArray *empty = @[];
    // Create a simple dictionary with shit to create a report.
    NSDictionary *dictionary = @{
                                 @"token":tokenfromstorage,
                                 @"title":title,
                                 @"subjectcode":what,
                                 @"address_line1":where,
                                 @"lat_reported_from":latitude.stringValue,
                                 @"lon_reported_from":longitude.stringValue,
                                 @"description":desc,
                                 @"offenses":empty,
                                 @"perpetrators":empty,
                                 @"property":empty};
    NSLog(@"%@ ~ LAT:%@ ~LONG:%@\n", where,latitude.stringValue,longitude.stringValue);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    [locationManager stopUpdatingLocation];
    
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
                                       NSLog(@"err?::: %@\n",error);
                                      // NSLog(@"response::: %@\n",response);
                                       apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           //TODO: alert user somehow of error?
                                       }else{
                                           //get and store token
                                           NSString *idfromJson = [responseDictionary objectForKey:@"id"];
                                           NSLog(@"ID: %@",idfromJson);
                                           dispatch_async(dispatch_get_main_queue(), ^{
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
                                                   //TODO: handle storing issues
                                               }
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
@end

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

@synthesize whereTextField;
@synthesize timePicker;
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
    pickerData = @[@"Theft", @"Property Damage", @"Burglary",@"Assault",@"Menacing", @"Vandalism",@"Robbery",@"Other"];
    subjectCodes = @[@"115",          @"551",                   @"6969",          @"254",           @"255",       @"554",        @"450",        @"0000"];
    subjectPicker.dataSource = self;
    subjectPicker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}


- (IBAction)postButtonTapped:(id)sender {
    
    NSString *where = whereTextField.text;
    NSDate *time = [timePicker date];
    NSString *what = [subjectCodes objectAtIndex:[subjectPicker selectedRowInComponent:0]];
    NSString *desc = descriptionTextField.text;
    if( [what isEqualToString:@""] || [desc isEqualToString:@""] || [where isEqualToString:@""] ){
        [self showAlert:@"Hmmmm..." withMessage:@"Some report information is mising"];
        return;
    }
    //get token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenfromstorage = [defaults stringForKey:@"token"];

    //get lat and long
    NSNumber *latitude = [NSNumber numberWithFloat:locationManager.location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:locationManager.location.coordinate.longitude];
    
    // URL of the endpoint we're going to contact.
    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/new"];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
	[DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	NSLog(@"%@",[NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:time]]);
    NSArray *empty = @[];
	
	
    // Create a simple dictionary with shit to create a report.
    NSDictionary *dictionary = @{
                                 @"token":tokenfromstorage,
                                 @"subjectcode":what,
                                 @"address_line1":where,
								 @"time_began":[DateFormatter stringFromDate:time],
								 @"time_ended":[DateFormatter stringFromDate:time],
                                 @"lat_reported_from":latitude.stringValue,
                                 @"lon_reported_from":longitude.stringValue,
                                 @"description":desc,
                                 @"offenses":empty,
                                 @"perpetrators":empty,
                                 @"property":empty};
    //NSLog(@"%@ ~ LAT:%@ ~LONG:%@\n", where,latitude.stringValue,longitude.stringValue);
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
                                           //alert user somehow of error?
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self showAlert:@"We encountered a problem" withMessage:apiresponse];
                                          });
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
                                                   //handle storing issues
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self showAlert:@"Something went amiss" withMessage:@"For some reason we couldnt process your report.\nSorry about that."];
                                                   });
                                               }
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

// The data to return for the row and component (column) that's being passed in
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *title = pickerData[row];
	NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
	return attString;
}


@end

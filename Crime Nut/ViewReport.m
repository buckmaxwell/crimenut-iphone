//
//  ViewReport.m
//  Crime Nut
//
//  Created by Allen White on 3/20/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "ViewReport.h"

#define METERS_MILE 1609.344
#define METERS_FEET 3.28084

@interface ViewReport ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *reportComments;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.commentTextField endEditing:YES];
}


//get lat, lon, desc, comments
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"id%@",reportId);
    //call for description & comments
    //get token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenfromstorage = [defaults stringForKey:@"token"];
    
    // URL of the endpoint we're going to contact.
    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/report"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Create a simple dictionary with numbers.
    NSDictionary *dictionary = @{@"reportid":self.reportId, @"token":tokenfromstorage};
    
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
                                       //NSLog(@"err::: %@\n",error);
                                       //NSLog(@"response::: %@\n",response);
                                       //NSLog(@"RespDict::: %@\n", responseDictionary);
                                       apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self showAlert:@"Something went amiss" withMessage:apiresponse];
                                           });
                                           
                                       }else{
                                           //shit worked
                                           NSString *desc = [responseDictionary objectForKey:@"description"];
                                           NSString *lon = [responseDictionary objectForKey:@"lon"];
                                           NSString *lat = [responseDictionary objectForKey:@"lat"];
                                           CLLocation *loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
                                           NSLog(@"lat:%@,lon:%@",lat,lon);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               self.descriptionLabel.text = desc;
                                               NSMutableArray * annotationsToRemove = [ self.mapView.annotations mutableCopy ] ;
                                               [ annotationsToRemove removeObject:self.mapView.userLocation ] ;
                                               [ self.mapView removeAnnotations:annotationsToRemove ] ;
                                               // zoom the map into the users current location
                                               MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate, 2*METERS_MILE, 2*METERS_MILE);
                                               [[self mapView] setRegion:viewRegion animated:YES];

                                               MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                               [annotation setCoordinate:loc.coordinate];
                                               [self.mapView addAnnotation:annotation];
                                               
                                               self.reportComments =  [responseDictionary objectForKey:@"comments"];
                                               NSLog(@"comments: %@",self.reportComments);
                                               [self getComments];
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


//still to come
- (void) getComments{
    NSString *comment = @"";
    commentsLabel.numberOfLines = 0;
    for (int i = 0; i < self.reportComments.count; i++) {
        comment = [NSString stringWithFormat:@"%@\n%@\n",
                   comment,
                   [[self.reportComments objectAtIndex:i] objectForKey:@"content"]];
    }
    commentsLabel.text = comment;
    //CGSize maxSize = CGSizeMake(320, 410);
    //CGRect labrect = [comment boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:commentsLabel.font} context:Nil];
    //commentsLabel.frame = CGRectMake(20, 460, 368, labrect.size.height);
}


//process the spam notification
- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0 && [@"This is spam" isEqualToString:[theAlert buttonTitleAtIndex:buttonIndex]]){
        //send the ol request for spam
        
        //get token
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *tokenfromstorage = [defaults stringForKey:@"token"];
        
        // URL of the endpoint we're going to contact.
        NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/spam/new"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // Create a simple dictionary with numbers.
        NSDictionary *dictionary = @{@"reportid":self.reportId, @"token":tokenfromstorage};
        
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
                                           //NSLog(@"err::: %@\n",error);
                                           //NSLog(@"response::: %@\n",response);
                                           NSLog(@"RespDict::: %@\n", responseDictionary);
                                           apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                           if (apiresponse) {
                                               NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self showAlert:@"Something went amiss" withMessage:apiresponse];
                                               });
                                               
                                           }else{
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self showAlert:@"Thanks!" withMessage:@"This post now has a lower priority than others."];
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
}



-(void)showAlert:(NSString *)title withMessage:(NSString *)message{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}


- (IBAction)postCommentTapped:(id)sender {
    NSString *comment = self.commentTextField.text;
    //get token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenfromstorage = [defaults stringForKey:@"token"];
    
    // URL of the endpoint we're going to contact.
    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/reports/comments/new"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Create a simple dictionary with numbers.
    NSDictionary *dictionary = @{@"report_id":self.reportId, @"token":tokenfromstorage,@"content":comment};
    NSLog(@"reportID: %@",self.reportId);
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
                                       //NSLog(@"err::: %@\n",error);
                                       //NSLog(@"response::: %@\n",response);
                                       //NSLog(@"RespDict::: %@\n", responseDictionary);
                                       apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self showAlert:@"Something went amiss" withMessage:apiresponse];
                                           });
                                           
                                       }else{
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self showAlert:@"We've posted your comment" withMessage:@"Thanks for being a Crime Kid!"];
                                               [self.commentTextField setUserInteractionEnabled:FALSE];
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



@end

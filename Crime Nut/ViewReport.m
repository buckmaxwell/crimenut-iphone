//
//  ViewReport.m
//  Crime Nut
//
//  Created by Allen White on 3/20/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "ViewReport.h"

@interface ViewReport ()

@end

@implementation ViewReport

@synthesize reportId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"id%@",reportId);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)spamButtonTapped:(id)sender {
    //alert user ~ ok or cancel
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"One sec!"
                                                       message:@"You are about to report this as spam. Are you sure?"
                                                      delegate:self
                                             cancelButtonTitle:@"This is spam"
                                             otherButtonTitles:@"Cancel",nil];
    [theAlert show];

    
}

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
                                                   UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Something went amiss"
                                                                                                      message:apiresponse
                                                                                                     delegate:self
                                                                                            cancelButtonTitle:@"OK"
                                                                                            otherButtonTitles:nil];
                                                   [theAlert show];
                                               });
                                               
                                           }else{
                                    
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Thanks!"
                                                                                                      message:@"This post now has a lower priority than others."
                                                                                                     delegate:self
                                                                                            cancelButtonTitle:@"OK"
                                                                                            otherButtonTitles:nil];
                                                   [theAlert show];
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
}


@end

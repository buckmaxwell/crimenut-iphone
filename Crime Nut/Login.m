//
//  Login.m
//  Crime Nut
//
//  Created by Allen White on 3/15/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "Login.h"
#import "Signup.h"
#import "CrimeFeed.h"


@interface Login ()

@end

@implementation Login

@synthesize usernameText;
@synthesize passwordText;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginTapped:(id)sender{
    NSString *uname = usernameText.text;
    NSString *pword = passwordText.text;
    
    // URL of the endpoint we're going to contact.

    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/users/login"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Create a simple dictionary with numbers.
    NSDictionary *dictionary = @{@"username":uname, @"password":pword};
    
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
    __block NSString *tokenfromstorage = [[NSString alloc] init];
    
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
                                           NSString *token = [responseDictionary objectForKey:@"token"];
                                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                           [defaults setObject:token forKey:@"token"];
                                           [defaults synchronize];
                                           tokenfromstorage = [defaults stringForKey:@"token"];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if(tokenfromstorage){
                                                   //send em to the main screen
                                                   CrimeFeed *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CrimeFeed"];
//                                                   [self presentViewController:controller animated:YES completion:nil];
                                                   
//                                                   CrimeFeed *controller = [[CrimeFeed alloc] initWithNibName:nil bundle:nil];
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

- (IBAction)needToSignupTapped:(id)sender{
    Signup *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Signup"];
    [self presentViewController:controller animated:YES completion:nil];
}


@end

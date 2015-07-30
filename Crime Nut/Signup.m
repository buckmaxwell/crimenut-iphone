//
//  Signup.m
//  Crime Nut
//
//  Created by Allen White on 3/14/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "Signup.h"
#import "Login.h"
#import "CrimeFeed.h"
#import "BasicModel.h"

@interface Signup ()

@end

@implementation Signup

@synthesize usernameTextField;
@synthesize passwordTextField;

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

- (IBAction)signupTapped:(id)sender {
    NSString *uname = usernameTextField.text;
    NSString *pword = passwordTextField.text;
    //NSLog(@"U= %@ .... P= %@", uname, pword);
    if( [uname isEqualToString:@""] || [pword isEqualToString:@""] ){
        [[BasicModel new] showAlert:@"Something went wrong" withMessage:@"Username and password are required"];
        return;
    }
    // URL of the endpoint we're going to contact.
    
    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/users/new"];
    
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
//                                       NSLog(@"err::: %@\n",error);
//                                       NSLog(@"response::: %@\n",response);
//                                       NSLog(@"RespDict::: %@\n", responseDictionary);
                                       apiresponse = [responseDictionary objectForKey:@"ERROR"];
                                       if (apiresponse) {
                                           NSLog(@"APIRESPONSEforerror:::%@", apiresponse);
                                           //alert user somehow of error?
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [[BasicModel new] showAlert:@"We encountered a problem" withMessage:[NSString stringWithFormat:@"%@",apiresponse]];
                                           });
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
                                                   UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                                                   //now present this navigation controller modally
                                                   [self presentViewController:navigationController
                                                                      animated:YES
                                                                    completion:^{
                                                                        
                                                                    }];
                                               }else{
                                                   //alert user somehow of storage error?
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [[BasicModel new] showAlert:@"We encountered a problem" withMessage:@"For some reason we could not save your information on this phone"];
                                                   });
                                               }
                                           });
                                       }
                                   }else{
                                       NSLog(@"STATUS: %ld\n",(long)statusCode);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[BasicModel new] showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"Bad connection: %ld",(long)statusCode]];
                                       });
                                   }
                               } else {
                                   NSLog(@"Error!!!! ,%@", [connectionError localizedDescription]);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[BasicModel new] showAlert:@"There seems to be a problem..." withMessage:[connectionError localizedDescription]];
                                   });
                               }
                           }];

}


- (IBAction)needToLoginTapped:(id)sender {
    Login *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    [self presentViewController:controller animated:YES completion:nil];
}

@end

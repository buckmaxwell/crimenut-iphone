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
    NSLog(@"U= %@ .... P= %@", uname, pword);
    
    // URL of the endpoint we're going to contact.

    NSURL *url = [NSURL URLWithString:@"http://crimenut.maxwellbuck.com/users/login"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Create a simple dictionary with numbers.
    NSDictionary *dictionary = @{@"username":uname, @"password":pword};
    
    // Convert the dictionary into JSON data.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:nil];
    NSString *strData = [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", strData);
    
    // Create a POST request with our JSON as a request body.
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:JSONData];
    
    
    __block NSMutableArray *response = [NSMutableArray array];
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
                                       NSLog(@"err:::%@\n",error);
                                       NSLog(@"response:::%@\n",response);
                                       // do something with response -----------------------------------------------------------------------------------------------------------------------------------
                                   }
                               } else {
                                   NSLog(@"Error,%@", [connectionError localizedDescription]);
                               }
                           }];

}

- (IBAction)needToSignupTapped:(id)sender{
    Signup *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Signup"];
    [self presentViewController:controller animated:YES completion:nil];
}


@end

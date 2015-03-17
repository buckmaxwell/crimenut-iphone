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
    NSLog(@"U= %@ .... P= %@", uname, pword);
    
    __block NSMutableArray *response = [NSMutableArray array];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.reddit.com/r/memes.json"]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request        queue:queue
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
                                       response = [[responseDictionary objectForKey:@"data"] objectForKey:@"children"];
                                       // do something with response -----------------------------------------------------------------------------------------------------------------------------------
                                       //save the ol token if we get one
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           //put shit inside here to run on another thread
                                       });
                                   }
                               } else {
                                   NSLog(@"Error,%@", [connectionError localizedDescription]);
                               }
                           }];

}

- (IBAction)needToLoginTapped:(id)sender {
    Login *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    [self presentViewController:controller animated:YES completion:nil];
}
@end

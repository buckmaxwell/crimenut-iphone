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
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           //put shit inside here to run on another thread
                                       });
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

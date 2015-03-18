//
//  CrimeFeed.m
//  Crime Nut
//
//  Created by Allen White on 3/14/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "CrimeFeed.h"
#import "Login.h"

@interface CrimeFeed ()

@end

@implementation CrimeFeed

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    //NSLog(@"token:::::%@", token);
    if(token){
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
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    //check if user is logged in
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    if(!token){
        //send they ass back to login bruh
        Login *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end

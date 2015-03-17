//
//  Login.h
//  Crime Nut
//
//  Created by Allen White on 3/15/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Login : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)loginTapped:(id)sender;
- (IBAction)needToSignupTapped:(id)sender;

@end

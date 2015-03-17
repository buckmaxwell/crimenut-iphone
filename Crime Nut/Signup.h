//
//  Signup.h
//  Crime Nut
//
//  Created by Allen White on 3/14/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Signup : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signupTapped:(id)sender;
- (IBAction)needToLoginTapped:(id)sender;


@end

//
//  AppDelegate.m
//  Crime Nut
//
//  Created by Allen White on 3/14/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "AppDelegate.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x666666)];
	[[UINavigationBar appearance] setTintColor:UIColor.whiteColor];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	// Register for Remote Notifications
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
	{
		UIUserNotificationSettings *settings =
		[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
		 UIUserNotificationTypeBadge |
		 UIUserNotificationTypeSound categories:nil];
		[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
	}
	else
	{
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
		 UIRemoteNotificationTypeAlert |
		 UIRemoteNotificationTypeBadge |
		 UIRemoteNotificationTypeSound];
	}
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
	
	NSString  *token_string = [[[[deviceToken description]    stringByReplacingOccurrencesOfString:@"<"withString:@""]
								stringByReplacingOccurrencesOfString:@">" withString:@""]
							   stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
	
	[defaults setObject:token_string forKey:@"APNSRegID"];
	[defaults setBool:YES forKey:@"tokenReady"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Did Fail to Register for Remote Notifications");
	NSLog(@"%@, %@", error, error.localizedDescription);
	
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	if (apsInfo) { //apsInfo is not nil
		NSMutableString *notificationType = [apsInfo objectForKey:@"alert"];
		
		NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
		NSString *apnstoken = [defaults stringForKey:@"APNSRegID"];
		
		//show crime
		
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

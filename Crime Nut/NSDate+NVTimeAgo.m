//
//  NSDate+NVTimeAgo.m
//
//  Created by Al Pal on 7/26/15.
//  Copyright (c) 2015 Al Pal. All rights reserved.
//

#import "NSDate+NVTimeAgo.h"

@implementation NSDate (NVFacebookTimeAgo)

#define SECOND  1
#define MINUTE  (SECOND * 60)
#define HOUR    (MINUTE * 60)
#define DAY     (HOUR   * 24)
#define WEEK    (DAY    * 7)
#define YEAR    (DAY    * 365.24)

+ (NSString *)mysqlDatetimeFormattedAsTimeAgo:(NSString *)mysqlDatetime
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSDate *date = [formatter dateFromString:mysqlDatetime];
	
	return [date formattedAsTimeAgo];
}


- (NSString *)formattedAsTimeAgo
{
	NSDate *now = [NSDate date];
	NSTimeInterval secondsSince = -(int)[self timeIntervalSinceDate:now];
	//Should never hit this but handle the future case
	if(secondsSince < 0)
		return @"In The Future";
	
	
	// < 1 minute = "Just now"
	if(secondsSince < MINUTE)
		return @"now";
	
	
	// < 1 hour = "x minutes ago"
	if(secondsSince < HOUR)
		return [self formatMinutesAgo:secondsSince];
	
	
	// Today = "x hours ago"
	if(secondsSince < DAY)
		return [self formatAsHoursAgo:secondsSince];
 
	
	// < Last 7 days = "Friday at 1:48 AM"
	if(secondsSince < WEEK)
		return [self formatAsDaysAgo:secondsSince];
	
	
	// < 1 year = "September 15"
	if(secondsSince < YEAR)
		return [self formatAsWeeksAgo:secondsSince];
	
	// Anything else = "September 9, 2011"
	return [self formatAsOther];
}




- (NSString *)formatMinutesAgo:(NSTimeInterval)secondsSince
{
	int minutesSince = (int)secondsSince / MINUTE;
	return [NSString stringWithFormat:@"%dm", minutesSince];
}



- (NSString *)formatAsHoursAgo:(NSTimeInterval)secondsSince
{
	int hoursSince = (int)secondsSince / HOUR;
	return [NSString stringWithFormat:@"%dh", hoursSince];
}



- (NSString *)formatAsDaysAgo:(NSTimeInterval)secondsSince
{
	int daysSince = (int)secondsSince / DAY;
	return [NSString stringWithFormat:@"%dd",daysSince];
}



- (NSString *)formatAsWeeksAgo:(NSTimeInterval)secondsSince
{
	int weeksSince = (int)secondsSince / WEEK;
	return [NSString stringWithFormat:@"%dw",weeksSince];
}



- (NSString *)formatAsOther
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"LLLL d, yyyy"];
	return [dateFormatter stringFromDate:self];
}


@end

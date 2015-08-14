//
//  NSDate+NVTimeAgo.h
//
//  Created by Al Pal on 7/26/15.
//  Copyright (c) 2015 Al Pal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NVFacebookTimeAgo)

+ (NSString*)mysqlDatetimeFormattedAsTimeAgo:(NSString *)mysqlDatetime;

- (NSString *)formattedAsTimeAgo;

@end

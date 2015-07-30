//
//  Perpatrator.h
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Perpatrator : NSObject

@property NSString *age;
@property NSString *gender;
@property NSString *race;
@property NSString *perpDescription;
-(NSDictionary *)getJson;
@end

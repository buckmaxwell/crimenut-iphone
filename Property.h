//
//  Property.h
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Property : NSObject

@property NSString *code;
@property NSString *propertyDescription;
@property NSString *model;
@property NSString *manufacturer;
@property NSString *value;
-(NSDictionary *)getJson;
@end

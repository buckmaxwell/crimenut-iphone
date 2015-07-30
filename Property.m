//
//  Property.m
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "Property.h"

@implementation Property

-(NSDictionary *)getJson{
	return @{
				@"code":		self.code,
				@"description":	self.propertyDescription,
				@"model":		self.model,
				@"manufacturer":self.manufacturer,
				@"value":		self.value};;
}

@end

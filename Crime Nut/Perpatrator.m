//
//  Perpatrator.m
//  Crimenut
//
//  Created by Allen White on 7/30/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "Perpatrator.h"

@implementation Perpatrator

-(NSDictionary *)getJson{
	return @{	@"age":			self.age,
				@"gender":		self.gender,
				@"race":			self.race,
				@"description":	self.perpDescription,};
}

@end

//
//  BasicModel.h
//  Crimenut
//
//  Created by Allen White on 7/29/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BasicModel : NSObject

-(void)callAPI:(NSURL *)url withJSONData:(NSData *)JSONData withCompletionBlock:(void (^)(NSDictionary *data))executeBlock
		andErrorResponseBlock:(void (^)(NSMutableArray *apiResponse))errorBlock;

-(void)fixSeparators:(UITableViewCell *)cell;

-(void)showAlert:(NSString *)title withMessage:(NSString *)message;

@end

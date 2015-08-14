//
//  BasicModel.m
//  Crimenut
//
//  Created by Allen White on 7/29/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "BasicModel.h"

@implementation BasicModel


-(void)callAPI:(NSURL *)url withJSONData:(NSData *)JSONData withCompletionBlock:(void (^)(NSDictionary *data))executeBlock
														andErrorResponseBlock:(void (^)(NSMutableArray *apiResponse))errorBlock{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:JSONData];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	__block NSMutableArray *apiresponse = [NSMutableArray array];
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	
	[NSURLConnection sendAsynchronousRequest:request
					   queue:queue
			       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
				       
				       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
				       NSInteger statusCode = [httpResponse statusCode];
				       if (!connectionError) {
					       if (statusCode != 500) {
						       NSError *error = nil;
						       NSDictionary *responseDictionary = [NSJSONSerialization
											   JSONObjectWithData:data
											   options:0
											   error:&error];
						       apiresponse = [responseDictionary objectForKey:@"ERROR"];
						       if (apiresponse) {
							       dispatch_async(dispatch_get_main_queue(), ^{
								       errorBlock(apiresponse);
							       });
						       }else{
							       dispatch_async(dispatch_get_main_queue(), ^{
								       executeBlock(responseDictionary);
							       });
						       }
					       }else{
						       dispatch_async(dispatch_get_main_queue(), ^{
							       [self showAlert:@"There seems to be a problem..." withMessage:[NSString stringWithFormat:@"Bad connection: %ld",(long)statusCode]];
						       });
					       }
				       } else {
					       dispatch_async(dispatch_get_main_queue(), ^{
						       [self showAlert:@"There seems to be a problem..." withMessage:[connectionError localizedDescription]];
					       });
				       }
			       }];
}



-(void)fixSeparators:(UITableViewCell *)cell{
	// Remove seperator inset
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	// Prevent the cell from inheriting the Table View's margin settings
	if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
	// Explictly set your cell's layout margins
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	[cell setNeedsUpdateConstraints];
	[cell updateConstraintsIfNeeded];
}


-(void)showAlert:(NSString *)title withMessage:(NSString *)message{
	UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:title
							   message:message
							  delegate:self
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
	[theAlert show];
}


@end

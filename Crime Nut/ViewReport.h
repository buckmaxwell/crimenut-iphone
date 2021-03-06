//
//  ViewReport.h
//  Crime Nut
//
//  Created by Allen White on 3/20/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ViewReport : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong,nonatomic) NSString *reportId;
- (IBAction)spamButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
- (IBAction)postCommentTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *commentsLabel;


@end

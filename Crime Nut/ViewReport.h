//
//  ViewReport.h
//  Crime Nut
//
//  Created by Allen White on 3/20/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ViewReport : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong,nonatomic) NSString *reportId;
- (IBAction)spamButtonTapped:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end

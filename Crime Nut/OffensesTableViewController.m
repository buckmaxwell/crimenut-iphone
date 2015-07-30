//
//  OffensesTableViewController.m
//  Crimenut
//
//  Created by Allen White on 7/29/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "OffensesTableViewController.h"
#import "OffensesTableViewCell.h"
#import "BasicModel.h"

@interface OffensesTableViewController ()

@end

@implementation OffensesTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.offenses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	OffensesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OffensesTableViewCell" forIndexPath:indexPath];
	cell.offenseLabel.text = [self.offenses objectAtIndex:indexPath.row];
	cell.subjectCode = [self.subjectCodes objectAtIndex:indexPath.row];
	[[BasicModel new] fixSeparators:cell];
	self.tableView.layer.shouldRasterize = YES;
	self.tableView.layer.rasterizationScale = [UIScreen mainScreen].scale;

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	OffensesTableViewCell *cell = (OffensesTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSString *thingClicked = cell.offenseLabel.text;
	NSString *code = cell.subjectCode;
	[self passDataBackToParentView:thingClicked withSubjectCode:code];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)passDataBackToParentView: (NSString *)thingClicked withSubjectCode:(NSString *)code
{
	[self.delegate pickedOffense:thingClicked withSubjectCode:code];
	[self.navigationController popViewControllerAnimated:YES];
}

@end

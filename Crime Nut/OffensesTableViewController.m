//
//  OffensesTableViewController.m
//  Crimenut
//
//  Created by Allen White on 7/29/15.
//  Copyright (c) 2015 crimenut. All rights reserved.
//

#import "OffensesTableViewController.h"
#import "OffensesTableViewCell.h"

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
    
	return cell;
}

@end

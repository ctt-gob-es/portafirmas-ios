//
//  SendersViewController.m
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 16/05/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import "SendersViewController.h"

@interface SendersViewController ()

@end

@implementation SendersViewController
@synthesize dataSource = _dataSource;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SendersCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    NSString *sender = [_dataSource objectAtIndex:[indexPath row]];
    cell.textLabel.text = sender;
    sender = nil;
    return cell;
}

@end

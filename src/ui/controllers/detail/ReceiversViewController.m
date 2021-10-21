//
//  SendersViewController.m
//  PortaFirmas_@Firma
//
//  Created by Antonio Fiñana Sánchez on 19/10/12.
//  Copyright (c) 2012 Luis Lopez. All rights reserved.
//

#import "ReceiversViewController.h"
#import "RequestListXMLController.h"
#import "Detail.h"
#import "SignLine.h"

@interface ReceiversViewController ()

@end

@implementation ReceiversViewController
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
    SignLine *signLine = [_dataSource objectAtIndex:0];
    self.listTitle.text = [NSString stringWithFormat:@"Firma en %@", signLine.type];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [_dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    SignLine *signLine = [_dataSource objectAtIndex:section];

    if (signLine.receivers) {
        return [signLine.receivers count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReceiversCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    SignLine *signLine = [_dataSource objectAtIndex:[indexPath section]];

    // Configure the cell...
    cell.textLabel.text = [signLine.receivers[indexPath.row] name];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SignLine *signLine = [_dataSource objectAtIndex:section];

    if ([signLine.receivers[0] isSign]) {
        return [[NSString alloc] initWithFormat:@"Linea %ld de firma", (long)section];
    } else {
        return [[NSString alloc] initWithFormat:@"Linea %ld de visto bueno", (long)section];
    }
}

#pragma mark - Table view delegate
@end

//
//  ProcessedRequestViewController.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana Sánchez on 23/10/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "ProcessedRequestViewController.h"

@interface ProcessedRequestViewController () <UIPopoverControllerDelegate>

@end

@implementation ProcessedRequestViewController

#pragma mark - Init Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.dataStatus = kBaseListVCDataStatusSigned;
    }

    return self;
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [self.parentViewController setHidesBottomBarWhenPushed:TRUE];
    [self.navigationController setToolbarHidden:YES];
    [self.parentViewController.tabBarController.tabBar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.parentViewController setHidesBottomBarWhenPushed:TRUE];
    [self.navigationController setToolbarHidden:YES];
}

- (void)goBack:(id)sender
{
    [self.parentViewController.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - User Interaction

- (IBAction)didTapOnBackButton:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueDetail"]) {
        [self prepareForDetailSegue:segue enablingSigning:NO];
    }
}

@end

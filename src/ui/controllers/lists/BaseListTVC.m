//
//  BaseListVC.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 6/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "BaseListTVC.h"
#import "RequestListXMLController.h"
#import "RequestCell.h"
#import "RequestCellNoUI.h"
#import "DetailTableViewController.h"
#import "ArrayHelper.h"
#import "GlobalConstants.h"

@interface BaseListTVC ()

@end

@implementation BaseListTVC

#pragma mark - Init methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        _currentPage = kBaseListVCMinPage;
        _moreDataAvailable = YES;
        _wsDataController = [[WSDataController alloc] init];
        [_wsDataController setDelegate:self];
        _dataArray = [@[] mutableCopy];
        _filtersDict = [NSMutableDictionary new];
    }

    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addPullToRefresh];
    [self addWatermark];
    [self setClearsSelectionOnViewWillAppear:NO];
    [_tableViewFooter setHidden:YES];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interface

- (void)addPullToRefresh
{
    UIRefreshControl *refreshControl = [UIRefreshControl new];

    [refreshControl addTarget:self action:@selector(refreshInfo) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)addWatermark
{
    UIImageView *watermarkIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_transp"]];

    [watermarkIV setFrame:self.view.bounds];
    [watermarkIV setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ];
    [watermarkIV setContentMode:UIViewContentModeCenter];
    [self.navigationController.view addSubview:watermarkIV];
    [self.navigationController.view sendSubviewToBack:watermarkIV];
}

#pragma mark - Lazy load methods

- (void)resetLazyLoad
{
    _currentPage = kBaseListVCMinPage;
}

#pragma mark - Network calls

- (void)loadDataWithProgressIndicator:(BOOL)showProgressIndicator
{
    if (showProgressIndicator) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD show];
		});
    }
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kPFUserDefaultsKeyUserConfigurationCompatible] == YES) {
        [self addDefaultFilters];
    }
    NSString *data = [RequestListXMLController buildDefaultRequestWithState:_dataStatus pageNumber:_currentPage filters:_filtersDict];
    [_wsDataController loadPostRequestWithData:data code:PFRequestCodeList];
    [_wsDataController startConnection];
}

- (void)loadData
{
    [self loadDataWithProgressIndicator:YES];
}

- (void)refreshInfo
{
    [self refreshInfoWithFilters:[NSMutableDictionary new]];
}

- (void)refreshInfoWithFilters:(NSDictionary *)filters {
    _filtersDict = [filters mutableCopy];
    [self resetLazyLoad];
    [self loadData];
}

- (void)addDefaultFilters {
    //Time default filter
    [_filtersDict setObject:kFilterMonthAll forKey:kFilterMonthKey];
    //Role selected filter
    NSDictionary *roleSelected = [[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyUserRoleSelected];
    if (![_filtersDict objectForKey:kFilterTypeKey]){
        if (roleSelected && [[[roleSelected objectForKey:kUserRoleRoleNameKey] objectForKey:kContentKey] isEqual: kUserRoleRoleNameValidator] ){
            [_filtersDict setObject: [[roleSelected objectForKey:kFilterDNIKey]objectForKey:kContentKey] forKey:kFilterDNIValidator];
            [_filtersDict setObject:kFilterTypeViewNoValidate forKey:kFilterTypeKey];
        } else {
            [_filtersDict setObject:kFilterTypeViewAll forKey:kFilterTypeKey];
        }
    }
}

#pragma mark - WSDelegate

- (void)doParse:(NSData *)data
{
    [self.refreshControl endRefreshing];

    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    RequestListXMLController *parser = [[RequestListXMLController alloc] initXMLParser];
    [nsXmlParser setDelegate:parser];
    BOOL success = [nsXmlParser parse];

    if (success) {
        BOOL finishOK = ![parser finishWithError];

        if (!finishOK) {
            [self didReceiveParserWithError:[NSString stringWithFormat:@"Mensaje del servidor:%@(%@)", [parser err], [parser errorCode]]];
            return;
        }

        if (self.currentPage == kBaseListVCMinPage) {
            self.dataArray = [parser dataSource];
        } else {
            [self.dataArray addObjectsFromArray:[parser dataSource]];
        }

        self.dataArray = [ArrayHelper getSortedArrayByExpirationDate: self.dataArray];
        [self setMoreDataAvailable:[parser dataSource].count > 0 && [parser dataSource].count % kRequestListXMLControllerPageSize == 0];
        [self.tableViewFooter setHidden:!self.moreDataAvailable];
        [self.tableView reloadData];
    } else {
        [self didReceiveError:@"Se ha producido un error de conexión con el servidor"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)didReceiveParserWithError:(NSString *)errorString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    [self setMoreDataAvailable:NO];
    [self.tableViewFooter setHidden:!self.moreDataAvailable];
    [self didReceiveError:errorString];
}

- (void)didReceiveError:(NSString *)errorString
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Error".localized
                                                                             message:errorString
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Ok".localized style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFRequest *request = self.dataArray[indexPath.row];

    return self.isEditing ? [self editinCellForRequest:request] : [self cellForRequest:request];
}

- (UITableViewCell *)editinCellForRequest:(PFRequest *)request
{
    RequestCellNoUI *editingCell = [self.tableView dequeueReusableCellWithIdentifier:kBaseListVCEditingCellIdentifier];

    if (!editingCell) {
        return nil;
    }

    [editingCell setPFRequest:request];

    return editingCell;
}

- (UITableViewCell *)cellForRequest:(PFRequest *)request
{
    RequestCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBaseListVCCellIdentifier];

    if (!cell) {
        return nil;
    }

    [cell setPFRequest:request];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int normalizedRow = (int)indexPath.row + 1;

    if (_moreDataAvailable && normalizedRow % kRequestListXMLControllerPageSize == 0 && self.dataArray.count == normalizedRow) {
        [_tableViewFooter setHidden:NO];
        self.currentPage++;
        [self loadDataWithProgressIndicator:NO];
    }
}

#pragma mark - Navigation Methods

- (void)prepareForDetailSegue:(UIStoryboardSegue *)segue enablingSigning:(BOOL)enableSign
{
    NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:true];
    DetailTableViewController *detailVC = [segue destinationViewController];
    PFRequest *selectedRequest = self.dataArray[selectedRow];
    [detailVC setDataSourceRequest:selectedRequest];
    [detailVC setSignEnabled:enableSign];
    [detailVC setRequestId:selectedRequest.reqid];
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD show];
	});
}

@end

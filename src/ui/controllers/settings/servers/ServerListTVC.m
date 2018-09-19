//
//  ServerListTVC.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 17/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "ServerListTVC.h"
#import "ServersListCell.h"
#import "AddServerVC.h"

static NSString *const kServerListTVCCellIdentifier = @"ServersListCell";
static long cellSelected;

@interface ServerListTVC ()
{
    NSMutableArray *_serversArray;
}

@end

@implementation ServerListTVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _serversArray = [[[[NSUserDefaults standardUserDefaults] arrayForKey:kPFUserDefaultsKeyServersArray] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *serverInfo1, NSDictionary *serverInfo2) {
        return [serverInfo1[kPFUserDefaultsKeyAlias] compare:serverInfo2[kPFUserDefaultsKeyAlias] options:NSCaseInsensitiveSearch];
    }] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _serversArray = nil;
}

#pragma mark - User Interaction
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    DDLogDebug(@"handleTapGesture");
    [self becomeFirstResponder];
    CGPoint p = [tapGesture locationInView: self.tableView];
    NSIndexPath *indexPathCell = [self.tableView indexPathForRowAtPoint: p];
    cellSelected = indexPathCell.row;
    
    // Show the menu
    CGRect targetRectangle = CGRectMake(p.x, p.y, 100, 100);
    [[UIMenuController sharedMenuController] setTargetRect:targetRectangle
                                                    inView:self.view];
    
    UIMenuItem *menuEdit = [[UIMenuItem alloc] initWithTitle:@"Editar"
                                                      action:@selector(editAction:)];
    UIMenuItem *menuSelected = [[UIMenuItem alloc] initWithTitle:@"Seleccionar"
                                                      action:@selector(selectAction:)];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    menuController.menuItems = [NSArray arrayWithObjects: menuEdit, menuSelected, nil];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    
}

- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    BOOL *result = NO;
    
    if (@selector(selectAction:) == action || @selector(editAction:) == action) {
        
        result = YES;
    }
    return result;
}

#pragma mark - UIMenuController Methods
- (void)selectAction:(id)sender {
    DDLogDebug(@"selectAction");
    DDLogDebug(@"Se ha seleccionado la celda %ld", cellSelected);
    NSDictionary *serverInfo = _serversArray[cellSelected];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", nil)
                                                                             message:[NSString stringWithFormat:NSLocalizedString(@"Alert_View_Server_Going_To_Be_Selected", nil), serverInfo[kPFUserDefaultsKeyAlias],serverInfo[kPFUserDefaultsKeyURL]]
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *accept = [UIAlertAction actionWithTitle:NSLocalizedString(@"Alert_View_Accept", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *serverInfo = _serversArray[cellSelected];
        [[NSUserDefaults standardUserDefaults] setObject:serverInfo forKey:kPFUserDefaultsKeyCurrentServer];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (_delegate) {
            [_delegate serverListDidSelectServer:serverInfo];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancel];
    [alertController addAction:accept];

    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) editAction: (id)sender {
    
    DDLogDebug(@"editAction");
    DDLogDebug(@"Se preciona la celda -> %ld", cellSelected);

    [self performSegueWithIdentifier:@"showEditServerVC" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"showEditServerVC"]) {
        
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        AddServerVC *vc = (AddServerVC *)navController.topViewController;
       
        NSArray *array = [[NSArray alloc] initWithObjects:
                                    _serversArray[cellSelected], nil];
        
        NSString *alias = (NSString *)[[array valueForKey:@"alias"]componentsJoinedByString: @""];
        NSString *url = [[array valueForKey:@"URL"]componentsJoinedByString: @""];
        
        vc.aliasTextField = [[UITextField alloc] init];
        vc.urlTextField = [[UITextField alloc] init];
        
        vc.aliasReceived = alias;
        vc.urlRecived = url;
        DDLogDebug(@"Alias %@", vc.aliasReceived);
        DDLogDebug(@"URL %@", vc.urlRecived);

    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _serversArray ? _serversArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServersListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kServerListTVCCellIdentifier];

    // Tap Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handleTapGesture:)];
    
    if (!cell) {
        DDLogError(@"ServersListVC::cellForRowAtIndexPath - Cell is nil");
        return nil;
    }
    
    [cell setServerInfo:_serversArray[indexPath.row]];
    
    cell.tag = indexPath.row;
    
    [cell addGestureRecognizer:tapGesture];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Eliminar";
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        [self updateCurrentServerRemovingServerAtIndexPath:indexPath];
        [_serversArray removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:_serversArray forKey:kPFUserDefaultsKeyServersArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)updateCurrentServerRemovingServerAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *removedServerInfo = _serversArray[indexPath.row];
    NSDictionary *currentServerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer];
    if ([removedServerInfo isEqualToDictionary:currentServerInfo]) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPFUserDefaultsKeyCurrentServer];
    }
}

@end

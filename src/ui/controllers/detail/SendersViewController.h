//
//  SendersViewController.h
//  PortaFirmasUniv
//
//  Created by Sergio Peñín on 16/05/18.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendersViewController : UITableViewController
{
    NSMutableArray* _dataSource;
}
@property (strong, nonatomic) NSMutableArray* dataSource;
@end

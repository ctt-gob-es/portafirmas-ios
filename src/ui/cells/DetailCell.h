//
//  DetailCell.h
//  PortaFirmasUniv
//
//  Created by Sergio PH on 15/05/2018.
//  Copyright © 2018 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell

-(void)setCellValue:(NSString *)value;
-(void)setCellTitle:(NSString *)value;

@property (strong, nonatomic) IBOutlet UITextView *sendersTitleTextView;
@property (strong, nonatomic) IBOutlet UITextView *sendersTextView;

@end

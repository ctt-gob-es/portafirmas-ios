//
//  SettingsCell.h
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 16/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, SettingsCellType)
{
    SettingsCellTypeServerURL,
    SettingsCellTypeCertificate,
	SettingsCellTypeRemoteCertificates
};

@class SettingsCell;
@protocol  SettingsCellDelegate <NSObject>

-(void) didSelectRemoveCertificates: (SettingsCell *)sender;

@end

@interface SettingsCell : UITableViewCell

@property (nonatomic, strong) UISwitch *remoteCertificatesSwitch;

@property (nonatomic, weak) id <SettingsCellDelegate> delegate;

- (void)setupForType:(SettingsCellType)type;

@end

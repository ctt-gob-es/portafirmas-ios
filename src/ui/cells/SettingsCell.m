//
//  SettingsCell.m
//  PortaFirmasUniv
//
//  Created by Rocio Tovar on 16/3/15.
//  Copyright (c) 2015 Atos. All rights reserved.
//

#import "SettingsCell.h"

#define KEYS_ARRAY @[kPFUserDefaultsKeyCurrentServer, kPFUserDefaultsKeyCurrentCertificate, kPFUserDefaultsKeyRemoteCertificates]

static NSString *const kSettingsCellUndefinedTitle = @"Sin especificar";

@interface SettingsCell ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

@implementation SettingsCell

- (void)setupForType:(SettingsCellType)type
{
    NSDictionary *typeDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:KEYS_ARRAY[type]];
    
    DDLogDebug(@"TypeDict -> %@", [typeDict allKeys]);
	
    if (typeDict && [typeDict.allKeys containsObject:kPFUserDefaultsKeyAlias]) {
        
        [_titleLabel setText:typeDict[kPFUserDefaultsKeyAlias]];
        [_titleLabel setTextColor:[UIColor blackColor]];
    } else if ((SettingsCellType)type == SettingsCellTypeRemoteCertificates) {
		[self setupForRemoteCertificatesCell];
	} else {
        [self setupForUndefinedValue];
    }
}

- (void) setupForRemoteCertificatesCell
{
	[_titleLabel setText:@"Remote certificates activated"];
	[_titleLabel setTextColor:[UIColor grayColor]];
	[self createSwitchInCell];
}

- (void)setupForUndefinedValue
{
    [_titleLabel setText:kSettingsCellUndefinedTitle];
    [_titleLabel setTextColor:[UIColor grayColor]];
}

-(void) createSwitchInCell
{
	CGRect myFrame = CGRectMake(20.0f, 10.0f, 250.0f, 25.0f);
	self.remoteCertificatesSwitch = [[UISwitch alloc] initWithFrame:myFrame];
	[self.remoteCertificatesSwitch setOn:YES];
	//attach action method to the switch when the value changes
	[self.remoteCertificatesSwitch addTarget:self
									  action:@selector(switchIsChanged:)
							forControlEvents:UIControlEventValueChanged];
	[self addSubview:self.remoteCertificatesSwitch];
}

@end

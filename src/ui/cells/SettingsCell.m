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
CGFloat const kLeftmarginForSwitch = 25;
CGFloat const kHalfHeightForSwitch = 16;

@interface SettingsCell ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

@implementation SettingsCell
@synthesize delegate;

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
	[_titleLabel setText:NSLocalizedString(@"settings_cell_remote_certificates_message", nil)];
	[_titleLabel setTextColor:[UIColor grayColor]];
	[self setAccessoryType:false];
	if (![self.subviews containsObject:self.remoteCertificatesSwitch]) {
		[self createSwitchInCell];
	} else {
		[self updateSwitch];
	}
}

- (void)setupForUndefinedValue
{
    [_titleLabel setText:kSettingsCellUndefinedTitle];
    [_titleLabel setTextColor:[UIColor grayColor]];
}

-(void) createSwitchInCell
{
	CGRect switchFrame = CGRectMake(_titleLabel.frame.size.width - kLeftmarginForSwitch, self.frame.size.height/2 - kHalfHeightForSwitch, self.remoteCertificatesSwitch.frame.size.width, self.remoteCertificatesSwitch.frame.size.height);
	self.remoteCertificatesSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
	[self setRemotesCertificatesSwitchState];
	[self.remoteCertificatesSwitch addTarget:self
									  action:@selector(switchIsChanged:)
							forControlEvents:UIControlEventValueChanged];
	[self addSubview:self.remoteCertificatesSwitch];
}

- (void) switchIsChanged:(UISwitch *)paramSender
{
	[[NSUserDefaults standardUserDefaults] setBool:[paramSender isOn] forKey:kPFUserDefaultsKeyRemoteCertificatesSelection];
	[[NSUserDefaults standardUserDefaults] synchronize];
	// Delete certificated selected if exists
	NSArray *userDefaultsKeys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys;
	if ([userDefaultsKeys containsObject:kPFUserDefaultsKeyCurrentCertificate]) {
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPFUserDefaultsKeyCurrentCertificate];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[self.delegate didSelectRemoveCertificates: self];
}

- (void)updateSwitch
{
	[self setRemotesCertificatesSwitchState];
}

-(void) setRemotesCertificatesSwitchState
{
	[self.remoteCertificatesSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsKeyRemoteCertificatesSelection]];
}

@end

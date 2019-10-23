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
	[self setAccessoryType:false];
	[self createSwitchInCell];
}

- (void)setupForUndefinedValue
{
    [_titleLabel setText:kSettingsCellUndefinedTitle];
    [_titleLabel setTextColor:[UIColor grayColor]];
}

-(void) createSwitchInCell
{
	CGRect switchFrame = CGRectMake(self.frame.size.width, self.frame.size.height/2, self.remoteCertificatesSwitch.frame.size.width, self.remoteCertificatesSwitch.frame.size.height);
	self.remoteCertificatesSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
	
	[self.remoteCertificatesSwitch setOn:YES];
	//attach action method to the switch when the value changes
	[self.remoteCertificatesSwitch addTarget:self
									  action:@selector(switchIsChanged:)
							forControlEvents:UIControlEventValueChanged];
	[self.remoteCertificatesSwitch setBackgroundColor: [UIColor blueColor]];
	
	[self addSubview:self.remoteCertificatesSwitch];
}

- (void) switchIsChanged:(UISwitch *)paramSender{
	if ([paramSender isOn]){
		NSLog(@"The switch is turned on.");
	} else {
		NSLog(@"The switch is turned off.");
	}
}

@end

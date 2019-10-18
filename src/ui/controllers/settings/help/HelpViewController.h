//
//  HelpViewController.h
//  PortaFirmasUniv
//
//  Created by Gonzalo Gonzalez  on 12/12/17.
//  Copyright © 2017 Solid Gear Projects S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface HelpViewController : UIViewController <WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

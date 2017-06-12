//
//  InformationWebView.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/2.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WebKit/WebKit.h>

@class InformationModel;
@class MailModel;

@interface InformationWebView : UIViewController <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) InformationModel *informationModel;
@property (nonatomic, strong) MailModel *mailModel;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *mailIdentifier; //留言标识，实现不同的动作方法

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

- (IBAction)commnetAction:(id)sender;
- (IBAction)shareAction:(id)sender;

@end

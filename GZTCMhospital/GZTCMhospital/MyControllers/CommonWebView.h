//
//  CommonWebView.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/16.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WebKit/WebKit.h>

@interface CommonWebView : UIViewController

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *linkUrl;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *courseFileDownloadItem;

@property (nonatomic, assign) BOOL refreshForAdd;

@end

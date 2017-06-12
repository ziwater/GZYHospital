  //
//  CommonWebView.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/16.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "CommonWebView.h"
#import <WebKit/WebKit.h>

#import "DownloadListTableView.h"

@interface CommonWebView () <WKNavigationDelegate>

@property (nonatomic, copy) NSString *courseFileListUrl;

@end

@implementation CommonWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configWebView]; //WebView界面设置
    
    //通知中心注册通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(showDownloadFileItem:) name:@"showDownloadFileItem" object:nil];
    
    //KVO注册通知 estimatedProgress及title
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    //加载网页请求
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.linkUrl]]];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebView界面设置

- (void)configWebView {
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero]; //初始化webview并设置其frame为CGRectZero
    
    [self.view insertSubview:self.webView belowSubview:self.progressView]; //在progressView下插入webView
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];  //禁止webView的自动约束
    
    //对webview的高添加约束: webView的高等于view的高
    id height = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    //对webview的宽添加约束
    id width = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.view addConstraints:@[height, width]];
    
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.navigationDelegate = self;
}

#pragma mark - BarButtonItem Action

- (void)back {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self close];
    }
}

- (void)close {
    if (self.refreshForAdd) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddForm" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddOrder" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddTreatmentPlan" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddSchedule" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddCourse" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddRemind" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddMemorandum" object:nil];
        
        self.refreshForAdd = NO;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //更新progressView的进度，如果加载完毕会隐藏progressView
    if ([keyPath isEqualToString: @"estimatedProgress"]) {
        if ([object isEqual:self.webView]) {
            self.progressView.hidden = self.webView.estimatedProgress == 1;
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if ([object isEqual:self.webView]) {
            self.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //当一个任务完成后，重置progressView的进度
    [self.progressView setProgress:0.0 animated:NO];
    
    NSLog(@"didFinishNavigation");
}

#pragma mark - NSNotificationCenter 通知方法

- (void)showDownloadFileItem:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = self.courseFileDownloadItem;
    self.courseFileListUrl = notification.object;
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showDownloadFileItem" object:nil];
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDownloadListJump"]) {
        DownloadListTableView *downloadListTableView = segue.destinationViewController;
        
        if ([downloadListTableView respondsToSelector:@selector(setAttachmentUrl:)]) {
            downloadListTableView.attachmentUrl = self.courseFileListUrl;
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

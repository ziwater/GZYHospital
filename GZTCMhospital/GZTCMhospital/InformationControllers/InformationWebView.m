//
//  InformationWebView.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/2.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "InformationWebView.h"

#import <WebKit/WebKit.h>
#import "UIViewController+ENPopUp.h"
#import "UMSocial.h"

#import "InformationModel.h"
#import "MailModel.h"
#import "DoctorSearchTableView.h"

@interface InformationWebView ()

@end

@implementation InformationWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configWebView]; //WebView界面设置
    
    //KVO注册通知
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    //加载网页请求
    if ([self.mailIdentifier isEqualToString:@"mail"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&MessageID=%@&TypeID=%@", MailDetailBaseUrl, GetOperatorID, self.mailModel.MessageID, self.mailModel.TypeID];
    } else {
        self.url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&PageID=1&PageSize=20",InformationWebViewBaseUrl, self.informationModel.FormID, self.informationModel.DetailID];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
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
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO]; //禁止webView的自动约束
    
    //对webview的高添加约束: webView的高等于view的高-40
    id height = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-40];
    //对webview的宽添加约束
    id width = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [self.view addConstraints:@[height, width]];
    
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.navigationDelegate = self;
    
    //设置评论按钮图标
    UIImage *originalImage = [UIImage imageNamed:@"icon_comment"];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 1, 0, 1);
    UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.commentButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //更新progressView的进度，如果加载完毕会隐藏progressView
    if ([keyPath isEqualToString: @"estimatedProgress"]) {
        self.progressView.hidden = self.webView.estimatedProgress == 1;
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
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
    [self.progressView setProgress:0.0 animated: false];
    
    NSLog(@"didFinishNavigation");
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)commnetAction:(id)sender {
    UINavigationController *commentNavigation = [self.storyboard instantiateViewControllerWithIdentifier:@"commentNavigation"];
    
    //拿到根控制器（也即CommentViewController）为其传值
    [commentNavigation.viewControllers.firstObject setValue:self forKey:@"delegate"];
    if ([self.mailIdentifier isEqualToString:@"mail"]) {
        [commentNavigation.viewControllers.firstObject setValue:self.mailModel forKey:@"mailModel"];
        [commentNavigation.viewControllers.firstObject setValue:self.mailIdentifier forKey:@"mailIdentifier"];
    } else {
        [commentNavigation.viewControllers.firstObject setValue:self.informationModel forKey:@"informationModel"];
    }
    
    [self presentPopUpViewController:commentNavigation];
}

- (IBAction)shareAction:(id)sender {  //分享、转发留言
    if ([self.mailIdentifier isEqualToString:@"mail"]) { //转发留言
        [self performSegueWithIdentifier:@"deliverMailForDoctorSearch" sender:nil];
    } else { //分享
        NSData *imageData = nil;
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.informationModel.PictureMicroimageUrl]];
        if (!imageData) {
            imageData = UIImagePNGRepresentation([UIImage imageNamed:@"share_default_icon"]);
        }
        
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"560403bae0f55a3219001fd4"
                                          shareText:self.informationModel.ContentSummary
                                         shareImage:imageData
                                    shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone]
                                           delegate:nil];
        //微信好友设置点击分享内容跳转链接
        [UMSocialData defaultData].extConfig.wechatSessionData.url = self.url;
        //设置微信好友title
        [UMSocialData defaultData].extConfig.wechatSessionData.title = self.informationModel.Title;
        
        //微信朋友圈设置点击分享内容跳转链接
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.url;
        //设置微信朋友圈title
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.informationModel.Title;
        
        [UMSocialData defaultData].extConfig.qqData.url = self.url; //QQ设置点击分享内容跳转链接
        [UMSocialData defaultData].extConfig.qqData.title = self.informationModel.Title; //QQ设置title
        
        [UMSocialData defaultData].extConfig.qzoneData.url = self.url; //Qzone设置点击分享内容跳转链接
        [UMSocialData defaultData].extConfig.qzoneData.title = self.informationModel.Title; //Qzone设置title
    }
}

//分享实现回调方法（可选）:
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess) {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"deliverMailForDoctorSearch"]) {
        DoctorSearchTableView *doctorSearchTableView = segue.destinationViewController;
        
        if ([doctorSearchTableView respondsToSelector:@selector(setDoctorSearchIdentify:)]) {
            [doctorSearchTableView setValue:self.mailIdentifier forKey:@"doctorSearchIdentify"];
        }
        
        if ([doctorSearchTableView respondsToSelector:@selector(setMailModel:)]) {
            [doctorSearchTableView setValue:self.mailModel forKey:@"mailModel"];
        }
    }
}

@end

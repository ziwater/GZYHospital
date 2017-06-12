//
//  CommentViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/10.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "CommentViewController.h"

#import "UIViewController+ENPopUp.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"

#import "CheckNetWorkStatus.h"
#import "InformationModel.h"
#import "ResultModel.h"
#import "MailModel.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTextView];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(commentTextViewChange) name:UITextViewTextDidChangeNotification object:self.commentTextView];
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置评论页的frame 高度:154 = 44+70+20*2
    self.navigationController.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 216.0 - 154.0 - 44.0, [UIScreen mainScreen].bounds.size.width, 154.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)commentTextViewChange {
    self.commentBarButtonItem.enabled = (self.commentTextView.text.length >= 2 && self.commentTextView.text.length <= 400);
}

#pragma mark - UITextView 设置

- (void)configTextView {
    //为UITextView添加边框及默认文本
    self.commentTextView.text = CommentPlaceHolder;
    self.commentTextView .textColor = [UIColor lightGrayColor];
    self.commentTextView.layer.borderColor = [RGBColor(215.0, 215.0, 215.0) CGColor];
    self.commentTextView.layer.borderWidth = 0.6f;
    self.commentTextView.layer.cornerRadius = 6.0f;
    
    [self.commentTextView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:CommentPlaceHolder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = CommentPlaceHolder;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action

- (IBAction)cancelCommentAction:(UIBarButtonItem *)sender {
     [self.delegate dismissPopUpViewController];
}

- (IBAction)sendCommentAction:(UIBarButtonItem *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
        [self performSegueWithIdentifier:@"commentLogin" sender:nil];
    } else { //已经登录
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            self.title = @"正在发送";
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            NSDictionary *parameters = nil;
            NSString *baseUrl = nil;
            if ([self.mailIdentifier isEqualToString:@"mail"]) {
                parameters = @{@"OperatorID": [userDefaults objectForKey:@"OperatorID"],
                               @"Content": self.commentTextView.text,
                               @"Title": self.mailModel.Title,
                               @"Sender": self.mailModel.Sender,
                               @"StafferName":GetStafferName,
                               @"PreMessageID":self.mailModel.MessageID,
                               @"InfoNoteTypeID":@"1"
                               };
                baseUrl = WriteOrReplyMailBaseUrl;
            } else {
                parameters = @{@"OperatorID": [userDefaults objectForKey:@"OperatorID"],
                                             @"DetailID": self.informationModel.DetailID,
                                             @"FormID": self.informationModel.FormID,
                                             @"Content": self.commentTextView.text
                                             };
                baseUrl = CommentBaseUrl;
            }
            
            [manager POST:baseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.resultModel = [ResultModel objectWithKeyValues:responseObject];
                
                if (self.resultModel.ResultID == 1) { //评论成功
                    [SVProgressHUD showSuccessWithStatus:self.resultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    [self.delegate dismissPopUpViewController]; //隐藏评论框
                } else { //评论失败
                    [SVProgressHUD showInfoWithStatus:self.resultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error = %@",error);
            }];
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
        }];
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"commentLogin"]) {
        //修改经由评论页跳转后的界面frame(通过修改其navigationController的frame)
        self.navigationController.view.frame =[UIScreen mainScreen].applicationFrame;
    }
}

@end

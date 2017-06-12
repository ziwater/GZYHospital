//
//  LoginTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "LoginTableView.h"
#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"

#import "CheckNetWorkStatus.h"
#import "LoginOrRegisterModel.h"
#import "MD5Method.h"
#import "RemindWayAndRecordModel.h"

@interface LoginTableView ()

@property (nonatomic, strong) NSArray *remindWayAndRecordModels;
@property (nonatomic, strong) RemindWayAndRecordModel *remindWayAndRecordModel;

@end

@implementation LoginTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:self.accountField];
    [center addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:self.pwdField];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)textChange {
    self.loginButton.enabled = (self.accountField.text.length >= 1 && self.pwdField.text.length >= 1);
}

#pragma mark - loginAction

- (IBAction)loginAction:(id)sender {
    [self.accountField resignFirstResponder];
    [self.pwdField resignFirstResponder];
    
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        [SVProgressHUD showWithStatus:LoginLoadingTip maskType:SVProgressHUDMaskTypeNone];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AFHTTPRequestOperationManager *manager=[CheckNetWorkStatus shareManager];
            
            NSDictionary *parameters = @{@"LoginID": self.accountField.text, @"Password": self.pwdField.text};
            [manager POST:LoginBaseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.loginModel = [LoginOrRegisterModel objectWithKeyValues:responseObject];
                
                if ([self.loginModel.ResultID isEqualToString:@"1"]) { //登录成功, 保存用户信息
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    
                    [userDefaults setObject:self.loginModel.OperatorID forKey:@"OperatorID"];
                    [userDefaults setObject:self.loginModel.StafferID forKey:@"StafferID"];
                    [userDefaults setObject:self.loginModel.StafferName forKey:@"StafferName"];
                    [userDefaults setObject:self.loginModel.PortraitMicroimageUrl forKey:@"PortraitMicroimageUrl"];
                    [userDefaults setObject:self.loginModel.StafferCard forKey:@"StafferCard"];
                    
                    [userDefaults synchronize];
                    
                    //登录成功,发出通知,通知”我的“页面显示用户名
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserInfo" object:self.loginModel.StafferName];
                    
                    //发出通知，通知"我的"页面显示用户头像
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPortrait" object:[userDefaults objectForKey:@"PortraitMicroimageUrl"]];
                    
                    //检测提醒管理是否需要红点提示
                    [self loadRemindWayAndRecordNumberJson];
                    
                    [SVProgressHUD dismiss];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else { //登录失败，给出错误提示
                    [SVProgressHUD showInfoWithStatus:self.loginModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showInfoWithStatus:LoginFailureTip maskType:SVProgressHUDMaskTypeNone];
                NSLog(@"error = %@",error);
            }];
        });
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//加载提醒管理-所有提醒方式和记录条数json并MD5化
- (void)loadRemindWayAndRecordNumberJson {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&PageID=1&PageSize=20", RemindWayAndRecordNumberBaseUrl, GetOperatorID];
        
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *jsonString = [NSString stringWithFormat:@"%@", responseObject];
            NSString *md5JsonString = [MD5Method md5:jsonString];
            
            self.remindWayAndRecordModels = [RemindWayAndRecordModel objectArrayWithKeyValuesArray:[[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"DataList"]];
            
            //保存该json的MD5值
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //无值或不相等则进行保存
            if ((![userDefaults objectForKey:@"remindWayAndRecordNumberJsonMD5"]) || (![[userDefaults objectForKey:@"remindWayAndRecordNumberJsonMD5"] isEqualToString:md5JsonString])) {
                [userDefaults setObject:md5JsonString forKey:@"remindWayAndRecordNumberJsonMD5"];
                [userDefaults synchronize];
                
                NSInteger i;
                for (i = 0; i < self.remindWayAndRecordModels.count; i++) {
                    self.remindWayAndRecordModel = self.remindWayAndRecordModels[i];
                    if (self.remindWayAndRecordModel.Count != 0) {
                        break;
                    }
                }
                
                if (i < self.remindWayAndRecordModels.count) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBadgeForItem" object:nil];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        
    }];
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

//
//  RegisterThirdTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/20.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "RegisterThirdTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "AMPopTip.h"

#import "LoginOrRegisterModel.h"
#import "CheckNetWorkStatus.h"
#import "ValidateInformation.h"

@interface RegisterThirdTableView ()

@property (nonatomic, strong) LoginOrRegisterModel *registerModel;
@property (nonatomic, strong) AMPopTip *popTip;

@end

@implementation RegisterThirdTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //消息中心注册通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(registerTextChange) name:UITextFieldTextDidChangeNotification object:self.passwordField];
    [center addObserver:self selector:@selector(registerTextChange) name:UITextFieldTextDidChangeNotification object:self.nameField];
    [center addObserver:self selector:@selector(registerTextChange) name:UITextFieldTextDidChangeNotification object:self.idCardNumberField];
    
    [self configPopTip];
    
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

- (void)registerTextChange {
    BOOL  enabled = ([ValidateInformation validatePassword:self.passwordField.text] && [ValidateInformation validateName:self.nameField.text] && [ValidateInformation validateIDCardNumber:self.idCardNumberField.text]);
    //发出通知，是否激活注册cell
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setEnableRegisterCell" object:[NSNumber numberWithBool:enabled]];
}

#pragma mark - AMPopTip 配置

- (void)configPopTip {
    
    [AMPopTip appearance].font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.popTip.popoverColor = [UIColor colorWithRed:0.95 green:0.65 blue:0.21 alpha:1];
    self.popTip.actionAnimation = AMPopTipActionAnimationFloat;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.passwordField] && ![ValidateInformation validatePassword:textField.text]) {
        [self.popTip showText:PasswordErrorTip direction:AMPopTipDirectionLeft maxWidth:200 inView:self.showPasswordErrorCell fromFrame:self.passwordErrorTips.frame duration:3];
    }
    if ([textField isEqual:self.nameField] && ![ValidateInformation validateName:textField.text]) {
        [self.popTip showText:NameErrorTip direction:AMPopTipDirectionLeft maxWidth:200 inView:self.showNameErrorCell fromFrame:self.nameErroTips.frame duration:3];
    }
    if ([textField isEqual:self.idCardNumberField] && ![ValidateInformation validateIDCardNumber:textField.text]) {
        [self.popTip showText:IdCardErrorTip direction:AMPopTipDirectionLeft maxWidth:200 inView:self.showIdCardErrorCell fromFrame:self.idCardErrorTips.frame duration:3];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGFLOAT_MIN; //取消分组静态表顶部的间隙
    return tableView.sectionHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) { //完成注册
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            [SVProgressHUD showWithStatus:RegisterLoadingTip maskType:SVProgressHUDMaskTypeNone];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                AFHTTPRequestOperationManager *manager=[CheckNetWorkStatus shareManager];
                
                NSDictionary *parameters = @{@"LoginID": self.mobilePhoneNumber,
                                             @"StafferName": self.nameField.text,
                                             @"StafferPhone": self.mobilePhoneNumber,
                                             @"StafferCard": self.idCardNumberField.text,
                                             @"Password": self.passwordField.text
                                             };
                
                [manager POST:RegisterBaseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    self.registerModel = [LoginOrRegisterModel objectWithKeyValues:responseObject];
                    
                    if (![self.registerModel.OperatorID isEqualToString:@"0"]) { //注册成功
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:self.registerModel.OperatorID forKey:@"OperatorID"];
                        [userDefaults setObject:self.registerModel.StafferID forKey:@"StafferID"];
                        [userDefaults setObject:self.registerModel.StafferName forKey:@"StafferName"];
                        [userDefaults synchronize];
                        
                        //注册成功,发出通知,通知”我的“页面显示用户名
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserInfo" object:self.registerModel.StafferName];
                        
                        [SVProgressHUD dismiss];
                        
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    } else { //注册失败，给出错误提示
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                        [SVProgressHUD showInfoWithStatus:self.registerModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [SVProgressHUD showInfoWithStatus:RegisterFailureTip maskType:SVProgressHUDMaskTypeNone];
                    NSLog(@"error = %@",error);
                }];
            });
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
            return;
        }];
    }
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

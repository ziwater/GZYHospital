//
//  RegisterSecondTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/20.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "RegisterSecondTableView.h"

#import "JKCountDownButton.h"
#import "SVProgressHUD.h"
#import "IQKeyboardManager.h"

#import "RegisterThirdTableView.h"

@interface RegisterSecondTableView ()

@end

@implementation RegisterSecondTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self getVerificationCodeAgainAction:self.getVerificationCodeButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}

#pragma mark - generateVerificationCode 产生验证码

- (NSString *)generateVerificationCode {
    NSArray *strArr = [[NSArray alloc]initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil] ;
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:6];
    for(int i = 0; i < 6; i++) { //得到六位随机字符,可自己设长度
        int index = arc4random() % ([strArr count]);  //得到数组中随机数的下标
        [getStr appendString:[strArr objectAtIndex:index]];
        
    }
    NSLog(@"验证码:%@",getStr);
    return getStr;
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGFLOAT_MIN; //取消分组静态表顶部的间隙
    if (section == 1)
        return 44;
    if (section == 2)
        return 30;
    return tableView.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        
        [headerView setText:[NSString stringWithFormat:@"%@%@",VerificationCodeAlreadySend, self.phone]];
        [headerView setTextAlignment:NSTextAlignmentCenter];
        [headerView setTextColor:[UIColor blackColor]];
        [headerView setFont:[UIFont systemFontOfSize:14.0]];
        [headerView setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        
        NSMutableAttributedString *styledText = [[NSMutableAttributedString alloc] initWithString:headerView.text];
        NSDictionary *attributes = @{
                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:headerView.font.pointSize],
                                     NSForegroundColorAttributeName: RGBColor(0, 194, 155)
                                     };
        NSRange range = [headerView.text rangeOfString:self.phone];
        [styledText setAttributes:attributes range:range];
        headerView.attributedText = styledText;
        
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) { //提交验证码
        if (self.verificationCodeTextField.text.length == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消提交验证码cell的灰色选中效果
            [SVProgressHUD showInfoWithStatus:VerificationCodeIsNullTip maskType:SVProgressHUDMaskTypeNone];
        } else if (![self.verificationCodeTextField.text isEqualToString:@"123456"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [SVProgressHUD showInfoWithStatus:VerificationCodeErrorTip maskType:SVProgressHUDMaskTypeNone];
        } else {
            [self.verificationCodeTextField resignFirstResponder];
            [self performSegueWithIdentifier:@"completeRegisterJump" sender:nil];
        }
    }
}

#pragma mark - Action method 重新获取验证码

- (IBAction)getVerificationCodeAgainAction:(JKCountDownButton *)sender {
    //button type要设置成custom 否则会闪动
    sender.enabled = NO;
    [sender startWithSecond:60];
    
    [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        NSString *title = [NSString stringWithFormat:@"(%ds)%@",second, ReAccessVerificationCode];
        return title;
    }];
    [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        return ReAccessVerificationCode;
    }];
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"completeRegisterJump"]) {
        UIViewController *viewController = segue.destinationViewController;
        if ([viewController respondsToSelector:@selector(setMobilePhoneNumber:)]) {
            [viewController setValue:self.phone forKey:@"mobilePhoneNumber"];
        }
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

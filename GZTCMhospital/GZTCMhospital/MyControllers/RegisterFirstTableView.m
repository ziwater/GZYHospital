//
//  RegisterFirstTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/20.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "RegisterFirstTableView.h"

#import "SVProgressHUD.h"
#import "IQKeyboardManager.h"

#import "ValidateInformation.h"
#import "RegisterSecondTableView.h"

@interface RegisterFirstTableView ()

@end

@implementation RegisterFirstTableView

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGFLOAT_MIN; //取消分组静态表顶部的间隙
    return tableView.sectionHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) { //获取验证码
        if (self.registerPhoneTextField.text.length == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消获取验证码cell的灰色选中效果
            [SVProgressHUD showInfoWithStatus:RegisterPhoneIsNullTip maskType:SVProgressHUDMaskTypeNone];
        } else if (![ValidateInformation validateMobile:self.registerPhoneTextField.text]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [SVProgressHUD showInfoWithStatus:PhoneErrorTip maskType:SVProgressHUDMaskTypeNone];
        } else {
            [self.registerPhoneTextField resignFirstResponder];
            [self performSegueWithIdentifier:@"submitVerificationCodeJump" sender:nil];
        }
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"submitVerificationCodeJump"]) {
        UIViewController *viewController = segue.destinationViewController;
        if ([viewController respondsToSelector:@selector(setPhone:)]) {
            [viewController setValue:self.registerPhoneTextField.text forKey:@"phone"];
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

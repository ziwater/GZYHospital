//
//  RegisterThirdTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/20.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterThirdTableView : UITableViewController

@property (nonatomic, copy) NSString *mobilePhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *idCardNumberField;

@property (weak, nonatomic) IBOutlet UIImageView *passwordErrorTips;
@property (weak, nonatomic) IBOutlet UIImageView *nameErroTips;
@property (weak, nonatomic) IBOutlet UIImageView *idCardErrorTips;

@property (weak, nonatomic) IBOutlet UITableViewCell *showPasswordErrorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showNameErrorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showIdCardErrorCell;

@end

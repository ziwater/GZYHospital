//
//  LoginTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  LoginOrRegisterModel;

@interface LoginTableView : UITableViewController

@property (nonatomic, strong) LoginOrRegisterModel *loginModel;

@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginAction:(id)sender;

@end

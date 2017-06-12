//
//  RegisterSecondTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/20.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKCountDownButton;

@interface RegisterSecondTableView : UITableViewController

@property (nonatomic, copy) NSString *phone;

@property (weak, nonatomic) IBOutlet JKCountDownButton *getVerificationCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

- (IBAction)getVerificationCodeAgainAction:(JKCountDownButton *)sender;

@end

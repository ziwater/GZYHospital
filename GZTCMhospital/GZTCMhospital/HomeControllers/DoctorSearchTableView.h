//
//  DoctorSearchTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/16.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MailModel;

@interface DoctorSearchTableView : UITableViewController

@property (nonatomic, copy) NSString *doctorSearchIdentify;

//留言转发
@property (nonatomic, strong) MailModel *mailModel;

@property (weak, nonatomic) IBOutlet UITextField *organizationName;
@property (weak, nonatomic) IBOutlet UITextField *doctorName;
@property (weak, nonatomic) IBOutlet UITextField *doctorPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *doctorStafferID;


@end

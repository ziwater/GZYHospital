//
//  DoctorListTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/22.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MailModel;

@interface DoctorListTableView : UITableViewController

@property (nonatomic, copy) NSString *doctorListIdentify;

@property (nonatomic, copy) NSString *doctorUrl;

@property (nonatomic, strong) MailModel *mailModel;

@end

//
//  TaskManageCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/5.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskManageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taskNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *wetherRemindTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *wetherRemindLabel;

@property (weak, nonatomic) IBOutlet UILabel *remindWayTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindWayLabel;

@property (weak, nonatomic) IBOutlet UILabel *RemindClassifyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *RemindClassifyLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeIntervalTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;

@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *createDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *modifyDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyTaskManageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteTaskManageButton;

@end

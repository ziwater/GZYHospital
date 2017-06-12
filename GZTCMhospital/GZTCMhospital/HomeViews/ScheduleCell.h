//
//  ScheduleCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/29.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *patientNameTipLabel;

@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *whetherHandleLabel;

@property (weak, nonatomic) IBOutlet UILabel *scheduleNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *beginDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *beginDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *scheduleCategoryTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleCategoryLabel;

@property (weak, nonatomic) IBOutlet UILabel *IDCardTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDCardLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;

@property (weak, nonatomic) IBOutlet UIButton *modifyScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteScheduleButton;

@end

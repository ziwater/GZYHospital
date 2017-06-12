//
//  RemindManageCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/7.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindManageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *eventTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *whetherAllDayTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *whetherAllDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *whetherHandleTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *whetherHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindWayTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindClassifyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindClassifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDCardTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

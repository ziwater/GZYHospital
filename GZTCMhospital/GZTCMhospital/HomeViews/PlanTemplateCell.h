//
//  PlanTemplateCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanTemplateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *templateNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *planClassifyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *planClassifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyPlanTemplateButton;
@property (weak, nonatomic) IBOutlet UIButton *deletePlanTemplateButton;

@end

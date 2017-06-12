//
//  PlanClassificationCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanClassificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *classifyNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *classifyNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *createDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateLabel;


@property (weak, nonatomic) IBOutlet UIButton *deletePlanClassificationButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyPlanClassificationButton;
@property (weak, nonatomic) IBOutlet UIView *separateView;


@end

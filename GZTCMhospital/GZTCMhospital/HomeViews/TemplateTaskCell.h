//
//  TemplateTaskCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/5.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateTaskCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *templateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateLabel;
@property (weak, nonatomic) IBOutlet UILabel *planClassifyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *planClassifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *diseaseDepartmentTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *diseaseDepartmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *planTaskTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *planTaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateDescriptionTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyTemplateTaskButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteTemplateTaskButton;

@end

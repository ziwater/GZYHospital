//
//  PatientTreatmentPlanCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/5.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientTreatmentPlanCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *patientNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDCardTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentPlanTemplateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentPlanTemplateLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentPlanClassifyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentPlanClassifyLabel;

@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyStafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyDateLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyPatientTreatmentPlanButton;
@property (weak, nonatomic) IBOutlet UIButton *deletePatientTreatmentPlanButton;

@end

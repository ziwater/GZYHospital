//
//  OrderResultCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIDTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *treatmentDataTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentTimeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationFeeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationFreeLabel;

@property (weak, nonatomic) IBOutlet UILabel *IDcardTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDcardLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationTypeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *specialistTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *specialistLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;

@property (weak, nonatomic) IBOutlet UILabel *doctorNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *doctorNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *createStafferNameTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createStafferNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *createTimeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteOrderButton;

@end

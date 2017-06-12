//
//  PatientSearchTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/15.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientSearchTableView : UITableViewController

@property (nonatomic, assign) NSInteger EditionID; //等同于DiplomateID（科室号）

@property (nonatomic, copy) NSString *patientSearchIdentify;

@property (weak, nonatomic) IBOutlet UITextField *patientHospitalizationNo;
@property (weak, nonatomic) IBOutlet UITextField *patientName;
@property (weak, nonatomic) IBOutlet UITextField *patientPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *patientIDCard;


@end

//
//  SearchScheduleTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/12.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchScheduleTableView : UITableViewController

@property (nonatomic, assign) NSInteger EditionID; //等同于DiplomateID（科室号）

@property (weak, nonatomic) IBOutlet UITextField *whetherProcessingFiled;
@property (weak, nonatomic) IBOutlet UITextField *searchDoctorName;
@property (weak, nonatomic) IBOutlet UITextField *searchNurseName;
@property (weak, nonatomic) IBOutlet UITextField *searchPatientName;
@property (weak, nonatomic) IBOutlet UITextField *searchIDCard;

@end

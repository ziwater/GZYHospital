//
//  ScheduleFunctionTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/30.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "ScheduleFunctionTableView.h"

#import "PatientListTableView.h"
#import "DoctorListTableView.h"
#import "NurseListTableView.h"

#import "ScheduleTableView.h"
#import "DiseaseListTableView.h"
#import "DoctorSearchTableView.h"
#import "NurseSearchTableView.h"

@interface ScheduleFunctionTableView ()

@end

@implementation ScheduleFunctionTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"schedulePatientListJump"]) {
        PatientListTableView *patientListTableView = segue.destinationViewController;
        
        if ([patientListTableView respondsToSelector:@selector(setPatientListIdentify:)]) {
            [patientListTableView setValue:@"schedulePatientListJump" forKey:@"patientListIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"doctorScheduleJump"]) {
        DoctorListTableView *doctorListTableView = segue.destinationViewController;
        
        if ([doctorListTableView respondsToSelector:@selector(setDoctorListIdentify:)]) {
            [doctorListTableView setValue:@"doctorScheduleJump" forKey:@"doctorListIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"nurseScheduleJump"]) {
        NurseListTableView *nurseListTableView = segue.destinationViewController;
        
        if ([nurseListTableView respondsToSelector:@selector(setNurseListIdentify:)]) {
            [nurseListTableView setValue:@"nurseScheduleJump" forKey:@"nurseListIdentify"];
        }
    }
    
    ///////////////////
    if ([segue.identifier isEqualToString:@"showPersonalScheduleJump"]) {
        ScheduleTableView *scheduleTableView = segue.destinationViewController;
        scheduleTableView.title = [NSString stringWithFormat:@"%@%@", GetStafferName, ScheduleTip];
        
        if ([scheduleTableView respondsToSelector:@selector(setScheduleUrl:)]) {
            
            NSString *url = nil;
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", DoctorScheduleBaseUrl, GetOperatorID, GetStafferName];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }

            [scheduleTableView setValue:url forKey:@"scheduleUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"scheduleDepartmentSelect"]) {  //科室日程- 科室选择
        DiseaseListTableView *diseaseListTableView = segue.destinationViewController;
        
        diseaseListTableView.title = DepartmentSelect;
        if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
            [diseaseListTableView setValue:@"scheduleDepartmentSelectIdentifier" forKey:@"identifier"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"schedulePatientDepartmentSelect"]) {  //病人日程- 科室选择
        DiseaseListTableView *diseaseListTableView = segue.destinationViewController;
        
        diseaseListTableView.title = DepartmentSelect;
        if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
            [diseaseListTableView setValue:@"schedulePatientDepartmentSelectIdentifier" forKey:@"identifier"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"scheduleDoctorSearch"]) {  //其他医生日程 - 医生搜索
        DoctorSearchTableView *doctorSearchTableView = segue.destinationViewController;
        if ([doctorSearchTableView respondsToSelector:@selector(setDoctorSearchIdentify:)]) {
            [doctorSearchTableView setValue:@"scheduleDoctorSearchIdentifier" forKey:@"doctorSearchIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"scheduleNurseSearch"]) { //其他护士日程 - 护士搜索
        NurseSearchTableView *nurseSearchTableView = segue.destinationViewController;
        if ([nurseSearchTableView respondsToSelector:@selector(setNurseSearchIdentify:)]) {
            [nurseSearchTableView setValue:@"scheduleNurseSearchIdentifier" forKey:@"nurseSearchIdentify"];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

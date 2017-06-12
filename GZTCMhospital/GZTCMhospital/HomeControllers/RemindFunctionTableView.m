//
//  RemindFunctionTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/7.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "RemindFunctionTableView.h"

#import "PatientListTableView.h"
#import "DoctorListTableView.h"
#import "NurseListTableView.h"
#import "RemindManageTableView.h"
#import "WZLBadgeImport.h"

#import "DiseaseListTableView.h"
#import "DoctorSearchTableView.h"
#import "NurseSearchTableView.h"

@interface RemindFunctionTableView ()

@end

@implementation RemindFunctionTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //若有新提醒， 在最新提醒栏显示new标识
    if ([self.showNewRemindBadge isEqualToString:@"showNewRemindBadge"]) {
        self.forBadgeLabel.badgeCenterOffset = CGPointMake(10, 22);
        [self.forBadgeLabel showBadgeWithStyle:WBadgeStyleNew value:0 animationType:WBadgeAnimTypeScale];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self.forBadgeLabel clearBadge];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBadgeForItem" object:nil];
        }
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"remindPatientListJump"]) {
        PatientListTableView *patientListTableView = segue.destinationViewController;
        
        if ([patientListTableView respondsToSelector:@selector(setPatientListIdentify:)]) {
            [patientListTableView setValue:@"remindPatientListJump" forKey:@"patientListIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindDoctorListJump"]) {
        DoctorListTableView *doctorListTableView = segue.destinationViewController;
        if ([doctorListTableView respondsToSelector:@selector(setDoctorListIdentify:)]) {
            [doctorListTableView setValue:@"remindDoctorListJump" forKey:@"doctorListIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindNurseListJump"]) {
        NurseListTableView *nurseListTableView = segue.destinationViewController;
        if ([nurseListTableView respondsToSelector:@selector(setNurseListIdentify:)]) {
            [nurseListTableView setValue:@"remindNurseListJump" forKey:@"nurseListIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"departmentRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        remindManageTableView.title = DepartmentRemindTip;
        
        if ([remindManageTableView respondsToSelector:@selector(setWhetherPullLoadIdentify:)]) {
            [remindManageTableView setValue:@"departmentRemind" forKey:@"whetherPullLoadIdentify"];
        }
        if ([remindManageTableView respondsToSelector:@selector(setEditionID:)]) {
            remindManageTableView.EditionID = self.EditionID;
        }
    }
    
    //////
    if ([segue.identifier isEqualToString:@"showPersonalRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        
        remindManageTableView.title = [NSString stringWithFormat:@"%@%@", GetStafferName,SomebodyRemindTip];
        if ([remindManageTableView respondsToSelector:@selector(setRemindUrl:)]) {
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", DoctorRemindBaseUrl, GetOperatorID, GetStafferName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [remindManageTableView setValue:url forKey:@"remindUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindDepartmentSelect"]) {  //科室提醒- 科室选择
        DiseaseListTableView *diseaseListTableView = segue.destinationViewController;
        
        diseaseListTableView.title = DepartmentSelect;
        if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
            [diseaseListTableView setValue:@"remindDepartmentSelectIdentifier" forKey:@"identifier"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindPatientDepartmentSelect"]) {  //病人提醒- 科室选择
        DiseaseListTableView *diseaseListTableView = segue.destinationViewController;
        
        diseaseListTableView.title = DepartmentSelect;
        if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
            [diseaseListTableView setValue:@"remindPatientDepartmentSelectIdentifier" forKey:@"identifier"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindDoctorSearch"]) {  //其他医生提醒 - 医生搜索
        DoctorSearchTableView *doctorSearchTableView = segue.destinationViewController;
        if ([doctorSearchTableView respondsToSelector:@selector(setDoctorSearchIdentify:)]) {
            [doctorSearchTableView setValue:@"remindDoctorSearchIdentifier" forKey:@"doctorSearchIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindNurseSearch"]) { //其他护士提醒 - 护士搜索
        NurseSearchTableView *nurseSearchTableView = segue.destinationViewController;
        if ([nurseSearchTableView respondsToSelector:@selector(setNurseSearchIdentify:)]) {
            [nurseSearchTableView setValue:@"remindNurseSearchIdentifier" forKey:@"nurseSearchIdentify"];
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

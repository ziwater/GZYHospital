//
//  OrderFunctionTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/30.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "OrderFunctionTableView.h"

#import "PatientListTableView.h"

#import "OrderResultTableView.h"
#import "DiseaseListTableView.h"
#import "DoctorSearchTableView.h"

@interface OrderFunctionTableView ()

@end

@implementation OrderFunctionTableView

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
    //    if ([segue.identifier isEqualToString:@"orderPatientListJump"]) {
    //        PatientListTableView *patientListTableView = segue.destinationViewController;
    //
    //        if ([patientListTableView respondsToSelector:@selector(setPatientListIdentify:)]) {
    //            [patientListTableView setValue:@"orderPatientListJump" forKey:@"patientListIdentify"];
    //        }
    //    }
    //
    if ([segue.identifier isEqualToString:@"orderCalenderDepartmentSelect"]) {
        DiseaseListTableView *diseaseListTableView = segue.destinationViewController;
        
        diseaseListTableView.title = DepartmentSelect;
        if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
            [diseaseListTableView setValue:@"orderCalendar" forKey:@"identifier"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"orderDepartmentSelect"]) {
        DiseaseListTableView *diseaseListTableView = segue.destinationViewController;
        
        diseaseListTableView.title = DepartmentSelect;
        if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
            [diseaseListTableView setValue:@"orderDepartmentSelectIdentifier" forKey:@"identifier"];
        }
    }
    if ([segue.identifier isEqualToString:@"showPersonalOrderJump"]) {
        OrderResultTableView *orderResultTableView = segue.destinationViewController;
        
        orderResultTableView.title = [NSString stringWithFormat:@"%@%@", GetStafferName,SomebodyOrderResultTip];
        if ([orderResultTableView respondsToSelector:@selector(setOrderResultUrl:)]) {
            NSString *url = nil;
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", OrderDoctorBaseUrl, GetOperatorID, GetStafferName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [orderResultTableView setValue:url forKey:@"orderResultUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"orderDoctorSearch"]) { //其他医生预约 - 医生搜索
        DoctorSearchTableView *doctorSearchTableView = segue.destinationViewController;
        if ([doctorSearchTableView respondsToSelector:@selector(setDoctorSearchIdentify:)]) {
            [doctorSearchTableView setValue:@"orderDoctorSearchIdentifier" forKey:@"doctorSearchIdentify"];
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

//
//  PatientSearchTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/15.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "PatientSearchTableView.h"

#import "PatientListTableView.h"

@interface PatientSearchTableView ()

@end

@implementation PatientSearchTableView

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

#pragma  mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消cell灰色选中效果
        [self performSegueWithIdentifier:@"showPatientSearchResult" sender:nil];
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPatientSearchResult"]) {
        PatientListTableView *patientListTableView = segue.destinationViewController;
        
        if ([patientListTableView respondsToSelector:@selector(setPatientUrl:)]) {
            
            NSString *url = nil;
            NSString *urlString = nil;
            
            urlString = [NSString stringWithFormat:@"%@OperatorID=%@&DiplomateID=%ld&PageID=1&PageSize=20&mzhzyh=%@&PatientName=%@&CardID=%@&Tel=%@", IdentifyAndEvaluatePatientListBaseUrl, GetOperatorID, (long)self.EditionID, self.patientHospitalizationNo.text, self.patientName.text, self.patientIDCard.text, self.patientPhoneNumber.text];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            [patientListTableView setValue:url forKey:@"patientUrl"];
        }
        
        if ([patientListTableView respondsToSelector:@selector(setPatientListIdentify:)]) {
            [patientListTableView setValue:self.patientSearchIdentify forKey:@"patientListIdentify"];
        }
        
        if ([patientListTableView respondsToSelector:@selector(setEditionID:)]) {
            [patientListTableView setValue:@(self.EditionID) forKey:@"EditionID"];
        }
    }
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

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

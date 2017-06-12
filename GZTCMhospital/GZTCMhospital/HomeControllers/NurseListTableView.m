//
//  NurseTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/30.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "NurseListTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "CheckNetWorkStatus.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UITableView+Improve.h"

#import "DoctorOrNurseListModel.h"
#import "ScheduleTableView.h"
#import "RemindManageTableView.h"

@interface NurseListTableView ()

@property (nonatomic, strong) NSArray *doctorOrNurseListModels;
@property (nonatomic, strong) DoctorOrNurseListModel *doctorOrNurseListModel;

@end

@implementation NurseListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [self loadNurseListData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadNurseListData 加载所有护士列表数据

- (void)loadNurseListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:self.nurseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.doctorOrNurseListModels = [DoctorOrNurseListModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.nurseListIdentify isEqualToString:@"nurseScheduleJump"]) {
        [self performSegueWithIdentifier:@"showNurseScheduleJump" sender:nil];
    }
    if ([self.nurseListIdentify isEqualToString:@"remindNurseListJump"]) {
        [self performSegueWithIdentifier:@"showNurseRemindJump" sender:nil];
    }
    
    ////
    if ([self.nurseListIdentify isEqualToString:@"scheduleNurseSearchIdentifier"]) {
        [self performSegueWithIdentifier:@"showNurseSearchScheduleJump" sender:nil];
    }
    
    if ([self.nurseListIdentify isEqualToString:@"remindNurseSearchIdentifier"]) {
        [self performSegueWithIdentifier:@"showNurseSearchRemindJump" sender:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doctorOrNurseListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nurseListCell" forIndexPath:indexPath];
    self.doctorOrNurseListModel = self.doctorOrNurseListModels[indexPath.row];
    
    cell.textLabel.text = self.doctorOrNurseListModel.syscodeName;
    
    return cell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    self.doctorOrNurseListModel = self.doctorOrNurseListModels[selectedIndexPath.row];
    
    if ([segue.identifier isEqualToString:@"showNurseScheduleJump"]) {
        ScheduleTableView *scheduleTableView = segue.destinationViewController;
        scheduleTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, ScheduleTip];
        
        if ([scheduleTableView respondsToSelector:@selector(setSyscodeName:)]) {
            [scheduleTableView setValue:self.doctorOrNurseListModel.syscodeName forKey:@"syscodeName"];
        }
    }
    
    /////
    if ([segue.identifier isEqualToString:@"showNurseSearchScheduleJump"]) {
        ScheduleTableView *scheduleTableView = segue.destinationViewController;
        
        scheduleTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, ScheduleTip];
        if ([scheduleTableView respondsToSelector:@selector(setScheduleUrl:)]) {
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", NurseScheduleBaseUrl, GetOperatorID, self.doctorOrNurseListModel.syscodeName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [scheduleTableView setValue:url forKey:@"scheduleUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showNurseSearchRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        
        remindManageTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, SomebodyRemindTip];
        if ([remindManageTableView respondsToSelector:@selector(setRemindUrl:)]) {
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", NurseRemindBaseUrl, GetOperatorID, self.doctorOrNurseListModel.syscodeName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [remindManageTableView setValue:url forKey:@"remindUrl"];
        }
    }
    
    //待定
    if ([segue.identifier isEqualToString:@"showNurseRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        remindManageTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, SomebodyRemindTip];
        
        if ([remindManageTableView respondsToSelector:@selector(setWhetherPullLoadIdentify:)]) {
            [remindManageTableView setValue:@"nurseRemind" forKey:@"whetherPullLoadIdentify"];
        }
        if ([remindManageTableView respondsToSelector:@selector(setSyscodeName:)]) {
            [remindManageTableView setValue:self.doctorOrNurseListModel.syscodeName forKey:@"SyscodeName"];
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

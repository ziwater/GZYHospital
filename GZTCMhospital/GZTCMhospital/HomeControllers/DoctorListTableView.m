//
//  DoctorListTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/22.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "DoctorListTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "CheckNetWorkStatus.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UITableView+Improve.h"

#import "DoctorOrNurseListModel.h"
#import "ScheduleTableView.h"
#import "RemindManageTableView.h"
#import "OrderResultTableView.h"
#import "ResultModel.h"
#import "MailModel.h"

@interface DoctorListTableView ()

@property (nonatomic, strong) NSArray *doctorOrNurseListModels;
@property (nonatomic, strong) DoctorOrNurseListModel *doctorOrNurseListModel;
@property (nonatomic ,strong) ResultModel *resultModel;

@end

@implementation DoctorListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [self loadDoctorListData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadDoctorListData 加载所有医生列表数据

- (void)loadDoctorListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:self.doctorUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.doctorListIdentify isEqualToString:@"doctorScheduleJump"]) {
        [self performSegueWithIdentifier:@"showDoctorScheduleJump" sender:nil];
    }
    if ([self.doctorListIdentify isEqualToString:@"remindDoctorListJump"]) {
        [self performSegueWithIdentifier:@"showDoctorRemindJump" sender:nil];
    }
    
    ////
    //根据doctorListIdentify执行不同的跳转
    if ([self.doctorListIdentify isEqualToString:@"orderDoctorSearchIdentifier"]) {
        [self performSegueWithIdentifier:@"showDoctorSearchOrderJump" sender:nil];
    }
    
    if ([self.doctorListIdentify isEqualToString:@"scheduleDoctorSearchIdentifier"]) {
        [self performSegueWithIdentifier:@"showDoctorSearchScheduleJump" sender:nil];
    }
    
    if ([self.doctorListIdentify isEqualToString:@"remindDoctorSearchIdentifier"]) {
        [self performSegueWithIdentifier:@"showDoctorSearchRemindJump" sender:nil];
    }
    if ([self.doctorListIdentify isEqualToString:@"mail"]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.doctorOrNurseListModel = self.doctorOrNurseListModels[indexPath.row];
        
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            NSDictionary *parameters = @{@"OperatorID": GetOperatorID,
                                         @"Title": self.mailModel.Title,
                                         @"Sender": self.doctorOrNurseListModel.syscodeName,
                                         @"StafferName":GetStafferName,
                                         @"PreMessageID":self.mailModel.MessageID,
                                         @"InfoNoteTypeID":@"2"
                                         };
            
            [manager POST:WriteOrReplyMailBaseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.resultModel = [ResultModel objectWithKeyValues:responseObject];
                
                if (self.resultModel.ResultID == 1) { //转发成功
                    [SVProgressHUD showSuccessWithStatus:self.resultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    
                    [self.navigationController popToViewController:[[self.navigationController childViewControllers] objectAtIndex:3] animated:YES];
                } else { //转发失败
                    [SVProgressHUD showInfoWithStatus:self.resultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error = %@",error);
            }];
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
        }];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"doctorListCell" forIndexPath:indexPath];
    self.doctorOrNurseListModel = self.doctorOrNurseListModels[indexPath.row];
    
    cell.textLabel.text = self.doctorOrNurseListModel.syscodeName;
    
    return cell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    self.doctorOrNurseListModel = self.doctorOrNurseListModels[selectedIndexPath.row];
    
    if ([segue.identifier isEqualToString:@"showDoctorScheduleJump"]) {
        ScheduleTableView *scheduleTableView = segue.destinationViewController;
        scheduleTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, ScheduleTip];
        
        if ([scheduleTableView respondsToSelector:@selector(setSyscodeName:)]) {
            [scheduleTableView setValue:self.doctorOrNurseListModel.syscodeName forKey:@"syscodeName"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showDoctorRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        remindManageTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, SomebodyRemindTip];
        
        if ([remindManageTableView respondsToSelector:@selector(setWhetherPullLoadIdentify:)]) {
            [remindManageTableView setValue:@"doctorRemind" forKey:@"whetherPullLoadIdentify"];
        }
        if ([remindManageTableView respondsToSelector:@selector(setSyscodeName:)]) {
            [remindManageTableView setValue:self.doctorOrNurseListModel.syscodeName forKey:@"SyscodeName"];
        }
    }
    
    /////
    if ([segue.identifier isEqualToString:@"showDoctorSearchOrderJump"]) {
        OrderResultTableView *orderResultTableView = segue.destinationViewController;
        
        orderResultTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, SomebodyOrderResultTip];
        if ([orderResultTableView respondsToSelector:@selector(setOrderResultUrl:)]) {
            NSString *url = nil;
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", OrderDoctorBaseUrl, GetOperatorID, self.doctorOrNurseListModel.syscodeName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [orderResultTableView setValue:url forKey:@"orderResultUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showDoctorSearchScheduleJump"]) {
        ScheduleTableView *scheduleTableView = segue.destinationViewController;
        
        scheduleTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, ScheduleTip];
        if ([scheduleTableView respondsToSelector:@selector(setScheduleUrl:)]) {
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", DoctorScheduleBaseUrl, GetOperatorID, self.doctorOrNurseListModel.syscodeName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [scheduleTableView setValue:url forKey:@"scheduleUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showDoctorSearchRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        
        remindManageTableView.title = [NSString stringWithFormat:@"%@%@", self.doctorOrNurseListModel.syscodeName, SomebodyRemindTip];
        if ([remindManageTableView respondsToSelector:@selector(setRemindUrl:)]) {
            NSString *url = nil;
            
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeName=%@&PageID=1&PageSize=20", DoctorRemindBaseUrl, GetOperatorID, self.doctorOrNurseListModel.syscodeName];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            } else {
                url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [remindManageTableView setValue:url forKey:@"remindUrl"];
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
